//
//  RawInputStabilizer.swift
//  RawInputStabilizer
//
//  Created by Lucas Soltic on 27/06/2020.
//  Copyright © 2019-2021 Yalir. All rights reserved.
//
//  Implementation of the stroke stabilizer from [OpenToonz](https://github.com/opentoonz/opentoonz)
//  project (SmoothStroke class in toonzrasterbrushtool.cpp), converted to the Swift language for
//  the purpose of the [ArtOverflow](https://artoverflow.io) drawing app for Mac, and with a few changes.
//

import Foundation
import CoreGraphics

public struct RawPoint: Equatable {
    public var position: CGPoint
    public var pressure: CGFloat
    
    public init(position: CGPoint, pressure: CGFloat) {
        self.position = position
        self.pressure = pressure
    }
}

/// This stroke stabilizer provides both a stabilized path and pressure. Other properties could be stabilized if needed by taking them into account
/// in the Smooth() function.
///
/// Changes with respect to the original OpenToonz implementation are as follow:
/// - In generatePoints(), CatmullRom is used to add more points only at the beginning of the stroke, this is to lower
/// computation time when later averaging the whole set of points. Starting from 10K points, smoothing requires too much
/// CPU time for real time output on a i7 8700K, so interpolating only at the stroke ends helps reaching this threshold much later.
/// Additionally the stylus input rate on macOS is quite enough to get smooth results in the middle of the stroke (removing it at the
/// ends give much less nicer thin stroke ends though, so it is kept).
/// - RawInputStabilizer provides an asynchronous API. This helps leveraging multicore power while keeping the main thread
/// free to spend its time on other work: GPU task scheduling in the case of ArtOverflow.
/// - Implementation of the Smooth() function is fixed to properly insert CatmullRom interpolated points at the beginning and end
/// of the generated array of points. Original implementation was inserting the end points around 10 items before the end.
/// - Unit tests are added, although a significant part of the value of this stabilizer is visual appreciation of the output.
///
/// Warning: Do NOT try to run this in debug mode unless you have plenty of time ahead or the dataset is very small.
public class RawInputStabilizer {
    public init(smoothing: UInt) {
        guard Thread.isMainThread else {
            fatalError("Unsupported configuration")
        }
        
        precondition((0...50).contains(smoothing))
        self.smoothing = smoothing
    }
    
    
    /// Synchronously add the given RawPoint to the stroke and eventually compute stabilized output points
    public func append(_ point: RawPoint) -> [RawPoint] {
        serialQueue.sync {
            self._append(point)
        }
    }
    
    /// Asynchronously add the given RawPoint to the stroke and eventually compute stabilized output points
    public func append(_ point: RawPoint, _ completionHandler: @escaping ([RawPoint]) -> Void) {
        serialQueue.async {
            let smoothed = self._append(point)
            DispatchQueue.main.sync {
                completionHandler(smoothed)
            }
        }
    }
    
    /// Asynchronously close the stroke and provide the remaining stabilized stroke points to the given closure
    public func closeStroke(_ completionHandler: @escaping ([RawPoint]) -> Void) {
        serialQueue.async {
            let smoothed = self._closeStroke()
            DispatchQueue.main.sync {
                completionHandler(smoothed)
            }
        }
    }
    
    // MARK: - Properties
    let smoothing: UInt
    private var outputIndex: Int = 0
    private var readIndex: Int = -1
    private var rawPoints = [RawPoint]()
    private var outputPoints = [RawPoint]()
    private let serialQueue = DispatchQueue(label: "Stabilizer Queue", qos: .userInteractive)
    
    // MARK: - Private methods
    private func _append(_ point: RawPoint) -> [RawPoint] {
        self.rawPoints.append(point)
        generatePoints()
        
        return self.smoothPoints
    }
    
    private func _closeStroke() -> [RawPoint] {
        defer {
            self.outputIndex = 0
            self.readIndex = -1
            self.rawPoints.removeAll()
            self.outputPoints.removeAll()
        }
        
        generatePoints()
        self.outputIndex = outputPoints.count - 1
        return self.smoothPoints
    }
    
    /// Get generated stroke points which has been smoothed.
    /// Both addPoint() and endStroke() generate new smoothed points.
    /// This method will remove generated points
    private var smoothPoints: [RawPoint] {
        let low = self.readIndex+1
        let up = min(self.outputIndex, outputPoints.count-1)
        self.readIndex = self.outputIndex
        return up >= low ? Array(self.outputPoints[low...up]) : []
    }
    
    private func generatePoints() {
        let n = self.rawPoints.count
        guard n > 0 else { return }
        
        // if smooth = 0, then skip whole smoothing process
        guard self.smoothing > 0 else {
            for i in self.outputIndex ..< self.outputPoints.count {
                if self.outputPoints[i] != self.rawPoints[i] {
                    break
                }
                self.outputIndex += 1
            }
            self.outputPoints = self.rawPoints
            return
        }
        
        var smoothedPoints = [RawPoint]()
        // Add more samples on stroke ends before applying the smoothing
        // This is because the raw inputs points are too few to support smooth result on stroke ends.
        // But increasing number of samples on the whole stroke makes smoothing too expensive.
        for i in 1..<n {
            let p1 = rawPoints[i-1]
            let p2 = rawPoints[i]
            let p0 = i-2 >= 0 ? rawPoints[i-2] : p1
            let p3 = i+1 < n ? rawPoints[i+1] : p2

            let distanceToEnd = (n-1 - i-1) / 3
            let distanceToStart = (i-1) / 3
            let baseSampling = 5
            let sampleCount = max(0, max(baseSampling - distanceToStart, baseSampling - distanceToEnd))
            if sampleCount > 0 {
                smoothedPoints += CatmullRomInterpolate(p0: p0, p1: p1, p2: p2, p3: p3, samples: sampleCount)
            }
            smoothedPoints.append(p2)
        }

        // Apply the 1D box filter
        // Multiple passes result in better quality and fix the stroke ends break issue
        for _ in 0..<3 {
            smoothedPoints = Self.Smooth(points: smoothedPoints,
                                         radius: Int(self.smoothing))
        }
        
        // Compare the new smoothed stroke with old one
        // Enable the output for unchanged parts
        let outputNum = outputPoints.count
        for i in self.outputIndex ..< outputNum {
            if outputPoints[i] != smoothedPoints[i] {
                break
            }
            outputIndex += 1
        }
        
        self.outputPoints = smoothedPoints
    }
    
    static func Smooth(points: [RawPoint], radius: Int) -> [RawPoint] {
        let n = points.count
        guard radius > 0 && n >= 3 else {
            return points
        }
        
        var result = [RawPoint]()
        let d = CGFloat(1.0) / CGFloat(radius * 2 + 1)
        
        for i in 1..<n {
            let lower = i - radius
            let upper = i + radius
            var total = points[0]
            total.position = .zero
            total.pressure = 0
            
            for j in lower...upper {
                let idx = j.clamped(0...n-1)
                total.position += points[idx].position
                total.pressure += points[idx].pressure
            }
            
            total.position *= d
            total.pressure *= d
            result.append(total)
        }
        
        var outPoints = result.dropLast() + [points.last!]
        if outPoints.count >= 3 {
            let pbase = outPoints.startIndex
            let prefix = CatmullRomInterpolate(p0: outPoints[pbase+0], p1: outPoints[pbase+0],
                                               p2: outPoints[pbase+1], p3: outPoints[pbase+2],
                                               samples: 10)
            outPoints.insert(contentsOf: prefix, at: outPoints.startIndex)

            let endPoints = outPoints.suffix(3)
            assert(endPoints.count == 3)
            let sbase = endPoints.startIndex
            let suffix = CatmullRomInterpolate(p0: endPoints[sbase+0], p1: endPoints[sbase+1],
                                               p2: endPoints[sbase+2], p3: endPoints[sbase+2],
                                               samples: 10)
            outPoints.append(contentsOf: suffix)
        }
        
        return Array(outPoints)
    }
}
