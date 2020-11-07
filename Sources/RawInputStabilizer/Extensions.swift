//
//  RawInputStabilizer.swift
//  RawInputStabilizer
//
//  Created by Lucas Soltic on 27/06/2020.
//  Copyright © 2020 Yalir. All rights reserved.
//

import CoreGraphics

extension Int {
    func clamped(_ range: Range<Int>) -> Int {
      (self < range.lowerBound) ? range.lowerBound : ((self >= range.upperBound) ? range.upperBound - 1: self)
    }

    func clamped(_ range: ClosedRange<Int>) -> Int {
      (self < range.lowerBound) ? range.lowerBound : ((self > range.upperBound) ? range.upperBound: self)
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
  left = left + right // swiftlint:disable:this shorthand_operator
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (left: inout CGPoint, right: CGFloat) {
  left = left * right // swiftlint:disable:this shorthand_operator superfluous_disable_command
}

extension CGPoint {
    func length() -> CGFloat {
      sqrt(x*x + y*y)
    }
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
      (self - point).length()
    }
}
