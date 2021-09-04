//
//  CatmullRom.swift
//  RawInputStabilizer
//
//  Created by Lucas Soltic on 27/06/2020.
//  Copyright © 2019-2021 Yalir. All rights reserved.
//
//  Implementation of the stroke stabilizer from [OpenToonz](https://github.com/opentoonz/opentoonz)
//  project (SmoothStroke class in toonzrasterbrushtool.cpp), converted to the Swift language for
//  the purpose of the [ArtOverflow](https://artoverflow.io) drawing app for Mac, and with a few changes.
//

import CoreGraphics

private func CatmullRomParams(v0: CGFloat, v1: CGFloat, v2: CGFloat, v3: CGFloat)
    -> (p0: CGFloat, p1: CGFloat, p2: CGFloat, p3: CGFloat) {
    typealias CG = CGFloat
    let p0 = v1
    let p1 = (-v0 + v2) * CG(0.5)
    let p2 = v0 - CG(2.5) * v1 + CG(2.0) * v2 - CG(0.5) * v3
    let p3 = CG(-0.5) * v0 + CG(1.5) * v1 - CG(1.5) * v2 + CG(0.5) * v3
    return (p0, p1, p2, p3)
}

func CatmullRomInterpolate(p0: RawPoint, p1: RawPoint, p2: RawPoint, p3: RawPoint,
                           samples: Int) -> [RawPoint] {
    guard samples > 0 else { return [] }

    let (x0, x1, x2, x3) = CatmullRomParams(v0: p0.position.x, v1: p1.position.x,
                                            v2: p2.position.x, v3: p2.position.x)
    let (y0, y1, y2, y3) = CatmullRomParams(v0: p0.position.y, v1: p1.position.y,
                                            v2: p2.position.y, v3: p2.position.y)
    let (p0, p1, p2, p3) = CatmullRomParams(v0: p0.pressure, v1: p1.pressure,
                                            v2: p2.pressure, v3: p3.pressure)

    return (1...samples).map { i in
        let t  = CGFloat(i) / CGFloat(samples + 1)
        let t2 = t * t
        let t3 = t2 * t
        let pos = CGPoint(x: x0 + x1 * t + x2 * t2 + x3 * t3,
                          y: y0 + y1 * t + y2 * t2 + y3 * t3)
        let pressure = p0 + p1 * t + p2 * t2 + p3 * t3
        return RawPoint(position: pos,
                        pressure: pressure)
    }
}
