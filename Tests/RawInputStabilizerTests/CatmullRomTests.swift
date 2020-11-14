//
//  CatmullRomTests.swift
//  RawInputStabilizerTests
//
//  Created by Lucas Soltic on 27/06/2020.
//  Copyright © 2020 Yalir. All rights reserved.
//

import XCTest
@testable import RawInputStabilizer

extension RawPoint {
    init(x: CGFloat, y: CGFloat, pressure: CGFloat) {
        self.init(position: CGPoint(x: x, y: y), pressure: pressure)
    }
}

final class CatmullRomTests: XCTestCase {
    let p0 = RawPoint(x: -1.0, y: 0.0, pressure: 1.0)
    let p1 = RawPoint(x:  0.0, y: 1.0, pressure: 1.0)
    let p2 = RawPoint(x:  1.0, y: 0.0, pressure: 10.0)
    let p3 = RawPoint(x:  2.0, y: 1.0, pressure: 10.0)
    
    func testInterpolateZeroSamples_generatesEmptyArray() throws {
        XCTAssertEqual([], CatmullRomInterpolate(p0: p0, p1: p1, p2: p2, p3: p3, samples: 0))
    }
    
    func testInterpolate10Samples_generates10Samples() throws {
        let interpolated = [
            RawPoint(x: 0.0946656649135988, y: 0.980465815176559, pressure: 1.5138993238166791),
            RawPoint(x: 0.19534184823441023, y: 0.9263711495116455, pressure: 2.210368144252442),
            RawPoint(x: 0.2997746055597295, y: 0.8444778362133735, pressure: 3.0488354620586025),
            RawPoint(x: 0.405709992486852, y: 0.7415477084898572, pressure: 3.988730277986477),
            RawPoint(x: 0.510894064613073, y: 0.6243425995492111, pressure: 4.989481592787378),
            RawPoint(x: 0.6130728775356874, y: 0.4996243425995493, pressure: 6.010518407212622),
            RawPoint(x: 0.709992486851991, y: 0.37415477084898563, pressure: 7.011269722013525),
            RawPoint(x: 0.7993989481592787, y: 0.2546957175056348, pressure: 7.951164537941398),
            RawPoint(x: 0.8790383170548459, y: 0.1480090157776106, pressure: 8.789631855747558),
            RawPoint(x: 0.946656649135988, y: 0.0608564988730278, pressure: 9.486100676183321)
        ]
        
        XCTAssertEqual(interpolated, CatmullRomInterpolate(p0: p0, p1: p1, p2: p2, p3: p3, samples: 10))
    }

    // swiftlint:disable:next empty_xctest_method
    static var allTests = [
        ("testInterpolateZeroSamples_generatesEmptyArray", testInterpolateZeroSamples_generatesEmptyArray),
        ("testInterpolate10Samples_generates10Samples", testInterpolate10Samples_generates10Samples)
    ]
}
