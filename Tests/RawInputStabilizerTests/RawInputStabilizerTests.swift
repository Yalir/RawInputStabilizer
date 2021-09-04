//
//  RawInputStabilizerTests.swift
//  RawInputStabilizerTests
//
//  Created by Lucas Soltic on 27/06/2020.
//  Copyright © 2019-2021 Yalir. All rights reserved.
//

import XCTest
@testable import RawInputStabilizer

extension RawPoint {
    static var random: RawPoint {
        RawPoint(x: CGFloat.random(in: -10...10),
                 y: CGFloat.random(in: -10...10),
                 pressure: CGFloat.random(in: 1...10))
    }
    
    static func generate(n: UInt) -> [RawPoint] {
        Array(1...n).map { _ in RawPoint.random }
    }
}

extension Array where Element == RawPoint {
    var averagePositionDistance: CGFloat {
        guard count > 1 else { return 0 }
        var average: CGFloat = 0.0
        for i in 1..<count {
            let dist = self[i-1].position.distanceTo(self[i].position)
            average += dist / CGFloat(count-1)
        }
        return average
    }
    
    var averagePressureDistance: CGFloat {
        guard count > 1 else { return 0 }
        var average: CGFloat = 0.0
        
        for i in 1..<count {
            let dist = abs(self[i-1].pressure - self[i].pressure)
            average += dist / CGFloat(count-1)
        }
        
        return average
    }
}

extension Array where Element: Comparable {
    var isMonotonic: Bool {
        guard count > 1 else { return true }
        
        for i in 1..<count where self[i-1] > self[i] {
            return false
        }
        
        return true
    }
}



final class RawInputStabilizerTests: XCTestCase {
    let manyRandomPoints = [
        RawPoint(x: 6.443113990519574, y: 6.736998256380492, pressure: 7.6842071809068395),
        RawPoint(x: 7.623875113877958, y: -6.505724830992086, pressure: 6.871000916957499),
        RawPoint(x: -3.2104896666407567, y: -0.9205021011319694, pressure: 8.339888557816753),
        RawPoint(x: 7.913569509794577, y: 8.641159057410036, pressure: 3.187554479977235),
        RawPoint(x: -4.914812224256089, y: 5.353743894578409, pressure: 6.820304903335222),
        RawPoint(x: 4.648101268452274, y: 5.649683100386458, pressure: 7.039691484571728),
        RawPoint(x: -6.1065551339833934, y: 0.6442873853787834, pressure: 5.590832086589032),
        RawPoint(x: 8.584089894604944, y: 9.710373438142884, pressure: 7.598797887631411),
        RawPoint(x: 7.047026526728722, y: 9.38109790814767, pressure: 9.937505974119713),
        RawPoint(x: 6.236780515139166, y: 4.321459186591518, pressure: 8.064561344604211),
        RawPoint(x: 4.194926738600142, y: 1.4398152520115985, pressure: 1.3089682399912959),
        RawPoint(x: -4.128024696963816, y: -3.30564384777436, pressure: 1.6133104998266352),
        RawPoint(x: -4.319764562987913, y: 7.424553564961041, pressure: 5.040579800358882),
        RawPoint(x: -7.41473669135464, y: 6.58282985076568, pressure: 1.447375910040658),
        RawPoint(x: 6.457666938871046, y: -6.154755150693241, pressure: 3.5099606573343483),
        RawPoint(x: -8.348802600345211, y: -3.7927801663634035, pressure: 6.813961328112321),
        RawPoint(x: -5.950246070492664, y: 6.964308856528472, pressure: 5.323754284796183),
        RawPoint(x: 3.8507197088920897, y: 8.990529952909736, pressure: 6.7456215799710275),
        RawPoint(x: -5.477896427986586, y: 9.606900519980343, pressure: 2.71896424426879),
        RawPoint(x: 2.4344666053544195, y: -0.7834507451722246, pressure: 9.86262812962443),
        RawPoint(x: 0.5497887106591666, y: 5.517190249702658, pressure: 8.3419047004753),
        RawPoint(x: -4.096697749447844, y: -9.486642944458396, pressure: 4.686565164325697),
        RawPoint(x: 8.42456374971266, y: -8.604109022877687, pressure: 6.139148098503377),
        RawPoint(x: -3.7696257993146993, y: 4.108294541990645, pressure: 6.4920978467774635),
        RawPoint(x: 9.939254700480646, y: -3.324633875051073, pressure: 6.462682253004077),
        RawPoint(x: 9.676045863689591, y: -2.189880709066494, pressure: 5.832357439003909),
        RawPoint(x: 5.7947734724791395, y: 2.678491400190378, pressure: 1.3242343820587936),
        RawPoint(x: -6.4350445014050965, y: -3.8406613088585946, pressure: 1.0373909078348573),
        RawPoint(x: 6.5924984397951505, y: -8.461017347216611, pressure: 7.691983202784114),
        RawPoint(x: -9.128263313854445, y: -7.875226113661872, pressure: 8.009077533546153),
        RawPoint(x: 3.2414168221627477, y: -5.344206337322146, pressure: 4.325775551651651),
        RawPoint(x: -1.5555282051646238, y: -0.3226460606945629, pressure: 4.67502640295869),
        RawPoint(x: -7.940318504506361, y: -0.07976401057980098, pressure: 7.210173818074953),
        RawPoint(x: 9.808433272798876, y: -0.217797127471421, pressure: 2.463605433395875),
        RawPoint(x: 1.0860775548973862, y: 7.908191473738544, pressure: 7.183784036286093),
        RawPoint(x: -0.8458418637340692, y: 4.379188229125962, pressure: 5.110043765234808),
        RawPoint(x: 9.454296839897207, y: -0.7863131716797334, pressure: 8.376834758453452),
        RawPoint(x: 5.989414836346201, y: -3.8957822526247554, pressure: 3.93633849908707),
        RawPoint(x: 3.6421746505129953, y: -8.400399132445662, pressure: 1.3593502403354396),
        RawPoint(x: 5.244041744846941, y: -5.690585534769326, pressure: 1.424634163912235),
        RawPoint(x: -2.397213778376339, y: 5.197168983380017, pressure: 1.753325153013421),
        RawPoint(x: 7.289677600611753, y: 9.122626057868427, pressure: 3.592646237228349),
        RawPoint(x: 7.58659397620535, y: -5.796247695393837, pressure: 2.188085191773591),
        RawPoint(x: -4.982028235099287, y: -3.989563038242614, pressure: 1.6870434734050952),
        RawPoint(x: -7.445204331935695, y: -9.220771273966808, pressure: 5.852088334250723),
        RawPoint(x: -5.481385494127204, y: 3.7386476518603544, pressure: 5.452175541330746),
        RawPoint(x: -4.477780782699526, y: -6.131582607772675, pressure: 9.011020277168097),
        RawPoint(x: -6.627599707278462, y: -8.592129204323918, pressure: 4.499707986947076),
        RawPoint(x: -9.290575731643123, y: 6.394918792566752, pressure: 1.4693112070067444),
        RawPoint(x: 9.971800111913495, y: -1.2331502771924434, pressure: 8.42773223333251),
        RawPoint(x: -7.163949796504497, y: 8.644674324228362, pressure: 4.304441003544733),
        RawPoint(x: 6.728172857599905, y: 5.691027963930939, pressure: 7.760843797703215),
        RawPoint(x: -1.816800191384722, y: 9.809354463158147, pressure: 3.5856959577927503),
        RawPoint(x: 5.184788933802324, y: -3.470981766652514, pressure: 3.7794052198496386),
        RawPoint(x: 0.9499414909410664, y: 4.4791428078715185, pressure: 5.569268154020824),
        RawPoint(x: 4.186572454155062, y: -9.980629417095672, pressure: 2.9885705994262723),
        RawPoint(x: -8.592381733983368, y: 1.3864180605589098, pressure: 1.1606709480119264),
        RawPoint(x: 5.4014793261860845, y: 0.7069297325866071, pressure: 8.876886625250005),
        RawPoint(x: 2.285352039318621, y: 2.859731368999139, pressure: 4.452136632048596),
        RawPoint(x: 6.826589416926147, y: -2.3956797701712285, pressure: 3.3403087448913853),
        RawPoint(x: 8.413415452220875, y: -1.7093159540020224, pressure: 4.947598891652001),
        RawPoint(x: -2.3119334785388768, y: -5.194147404735081, pressure: 2.2863460878846653),
        RawPoint(x: 5.02541743481447, y: 0.2862332599007722, pressure: 6.306627413911802),
        RawPoint(x: -0.7093893999801519, y: -9.46658526937405, pressure: 6.960490032006582),
        RawPoint(x: 9.03174478469153, y: -1.0883410460992398, pressure: 1.4401451200001836),
        RawPoint(x: -3.101234361100918, y: 6.593061211938892, pressure: 6.250987222051818),
        RawPoint(x: 8.862988329942244, y: -5.125859478493531, pressure: 2.2256936613893488),
        RawPoint(x: -8.57957118436995, y: -6.433957635177787, pressure: 5.075813050253629),
        RawPoint(x: -2.744081293096345, y: 4.408709579187091, pressure: 5.049535034369288),
        RawPoint(x: -1.5771679248121568, y: -5.314126492100599, pressure: 5.337913948140397),
        RawPoint(x: 6.292639857993354, y: -7.4797132694626045, pressure: 8.960299240705742),
        RawPoint(x: -3.9717568267280123, y: 7.073192440725574, pressure: 5.590594890762998),
        RawPoint(x: -2.0076450265571815, y: -0.5524255859050591, pressure: 2.9938964632284004),
        RawPoint(x: 5.834957022473109, y: 4.359849015288251, pressure: 1.5601632376706083),
        RawPoint(x: -1.549703080085136, y: 7.310215188918676, pressure: 6.731262164627182),
        RawPoint(x: -8.279437014839662, y: -7.6652236500361015, pressure: 1.6753567512227159),
        RawPoint(x: 6.316057303321596, y: 1.1045304408766903, pressure: 8.178969102892406),
        RawPoint(x: 9.46313367078979, y: 7.94773026252145, pressure: 6.712064492781312),
        RawPoint(x: -8.862102959204543, y: -5.075794866501326, pressure: 6.278679344171057),
        RawPoint(x: 6.527195377368766, y: 8.86647484837924, pressure: 4.754360010324966),
        RawPoint(x: -9.87169181753371, y: 9.19395880237542, pressure: 4.1216139107739105),
        RawPoint(x: -0.17183648847912636, y: 7.958137253188134, pressure: 5.182731465944785),
        RawPoint(x: 1.1569710777016056, y: -4.4356331134224565, pressure: 8.922791139466849),
        RawPoint(x: -9.978626623184514, y: -7.932478760402628, pressure: 3.6766294517379325),
        RawPoint(x: 3.325392720619904, y: 4.9666974541994335, pressure: 8.428584740557799),
        RawPoint(x: 2.2689493415684954, y: 2.646937256080493, pressure: 4.314634774472573),
        RawPoint(x: 0.5356575721005541, y: 2.001470109563538, pressure: 8.470013550936645),
        RawPoint(x: -2.1046219554263086, y: -6.587440732754022, pressure: 2.9715674727171164),
        RawPoint(x: 5.5786837318721005, y: 1.0151129988380152, pressure: 7.896060183823316),
        RawPoint(x: -1.1857928656769356, y: 7.4106556137662665, pressure: 3.3394379320645595),
        RawPoint(x: 0.03218649473444657, y: 7.05352432068425, pressure: 7.072900789945622),
        RawPoint(x: -5.789027226928505, y: 8.417217489618874, pressure: 2.31607810758602),
        RawPoint(x: 3.3027546398586853, y: 5.557099730718903, pressure: 4.2936355639831385),
        RawPoint(x: -3.981616763749538, y: -3.9167607133038063, pressure: 8.65646167699189),
        RawPoint(x: 6.184693055667864, y: 5.9359484485974505, pressure: 8.431451593164777),
        RawPoint(x: 1.1672830030205859, y: 4.082855198348794, pressure: 8.885067980906587),
        RawPoint(x: 5.7202834423648525, y: -7.604253732391538, pressure: 3.715082936555364),
        RawPoint(x: 4.069112395704693, y: -4.577967550939055, pressure: 6.826259079997659),
        RawPoint(x: -1.0061850364749692, y: 9.07537530069273, pressure: 4.537716087908991),
        RawPoint(x: -6.496967194307029, y: 5.122316996768356, pressure: 4.2290715288889364)
    ]
    
    func testSmooth_nullRadius_returnUnchanged() {
        let rawPoints = RawPoint.generate(n: 100)
        XCTAssertEqual(rawPoints, RawInputStabilizer.Smooth(points: rawPoints, radius: 0))
    }
    
    func testSmooth_manyRadii_returnSmoothedPosition() {
        let rawPoints = manyRandomPoints
        let smoothed = Array(stride(from: 1, to: 50, by: 5))
            .map { RawInputStabilizer.Smooth(points: rawPoints, radius: $0) }
        
        let baseDist = rawPoints.averagePositionDistance
        let distances = smoothed.map { $0.averagePositionDistance }
        let counts = smoothed.map { $0.count }
        XCTAssertEqual(distances, distances.sorted().reversed())
        XCTAssertTrue(distances.allSatisfy { $0 < baseDist })
        XCTAssertTrue(counts.allSatisfy { $0 >= rawPoints.count })
        XCTAssertTrue(distances.reversed().isMonotonic)
    }
    
    func testSmooth_manyRadii_returnSmoothedPressure() {
        let rawPoints = manyRandomPoints
        let smoothed = Array(stride(from: 1, to: 50, by: 5))
            .map { RawInputStabilizer.Smooth(points: rawPoints, radius: $0) }
        
        let baseDist = rawPoints.averagePressureDistance
        let distances = smoothed.map { $0.averagePressureDistance }
        XCTAssertEqual(distances, distances.sorted().reversed())
        XCTAssertTrue(distances.allSatisfy { $0 < baseDist })
        XCTAssertTrue(distances.reversed().isMonotonic)
    }
    
    func testSmooth_regressionTest() {
        let rawPoints = [
            RawPoint(x:  4.934228003809604,  y: -1.231373934919608,  pressure: 4.53898857886708),
            RawPoint(x:  0.21306836072205293,y: -9.068555432177952,  pressure: 7.538795692618186),
            RawPoint(x: -4.683175482376107,  y: -2.9923432158645706, pressure: 3.6256478458721078),
            RawPoint(x:  5.81296657004669,   y:  6.922822070174725,  pressure: 3.4498860476249673),
            RawPoint(x:  5.081333411540214,  y:  1.5105455201062075, pressure: 9.602908819367713),
            RawPoint(x:  0.930279515561903,  y: -2.2516828057717024, pressure: 1.8050276188190837),
            RawPoint(x:  2.005408030081597,  y:  0.8340246902578645, pressure: 8.668910018412035),
            RawPoint(x: -2.437283687244072,  y:  2.0370835501506352, pressure: 1.5696297734004776),
            RawPoint(x:  4.946506634546136,  y:  5.871941044683169,  pressure: 5.331639210382639),
            RawPoint(x:  2.4019768533874934, y:  4.090560620986006,  pressure: 3.1725691900771804)
        ]
        
        let smoothed = [
            RawPoint(x: 2.9997502447864703, y: -1.0542732031983932, pressure: 5.380368688735937),
            RawPoint(x: 2.9554863514420986, y: -1.065552779639068,  pressure: 5.344382109622592),
            RawPoint(x: 2.902197780813923,  y: -1.0791320755482297, pressure: 5.300016998003213),
            RawPoint(x: 2.842463012125887,  y: -1.0943540282205966, pressure: 5.250363783209011),
            RawPoint(x: 2.778860524601935,  y: -1.1105615749508864, pressure: 5.198512894571203),
            RawPoint(x: 2.7139687974660114, y: -1.127097653033817,  pressure: 5.147554761421003),
            RawPoint(x: 2.650366309942059,  y: -1.143305199764107,  pressure: 5.100579813089623),
            RawPoint(x: 2.5906315412540235, y: -1.1585271524364738, pressure: 5.0606784789082795),
            RawPoint(x: 2.5373429706258475, y: -1.1721064483456356, pressure: 5.0309411882081845),
            RawPoint(x: 2.493079077281476,  y: -1.18338602478631,   pressure: 5.014458370320554),
            RawPoint(x: 3.0324109816230944, y: -1.0459504089314877, pressure: 5.404886306012031),
            RawPoint(x: 2.4604183404448516, y: -1.1917088190532155, pressure: 5.014320454576603),
            RawPoint(x: 2.0420154870551364, y: -0.8966518725992909, pressure: 5.604309231654452),
            RawPoint(x: 0.9889423883331825, y: -0.42972937473211326,pressure: 5.180115116587795),
            RawPoint(x: 1.6651478560223372, y:  1.7046272648194754, pressure: 4.864807047697003),
            RawPoint(x: 2.677312475417137,  y:  2.7164706700838437, pressure: 4.800081525440586),
            RawPoint(x: 2.190028230180109,  y:  2.311861891628312,  pressure: 4.760464831505186),
            RawPoint(x: 1.8072630075868634, y:  2.6804354774682833, pressure: 3.841844884463682),
            RawPoint(x: 2.4019768533874934, y:  4.090560620986006,  pressure: 3.1725691900771804),
            RawPoint(x: 1.8268422646501132, y:  2.774799256731503,  pressure: 3.7691206544671005),
            RawPoint(x: 1.8639495555720325, y:  2.8925067480488322, pressure: 3.6959331151131596),
            RawPoint(x: 1.9150412449336998, y:  3.028032008442368,  pressure: 3.6232287685244673),
            RawPoint(x: 1.976573697316195,  y:  3.175849094934211,  pressure: 3.551954116823636),
            RawPoint(x: 2.045003277300597,  y:  3.3304320645464602, pressure: 3.483055662133275),
            RawPoint(x: 2.116786349467985,  y:  3.4862549743012137, pressure: 3.4174799065759953),
            RawPoint(x: 2.1883792783994394, y:  3.6377918812205703, pressure: 3.356173352274407),
            RawPoint(x: 2.2562384286760375, y:  3.779516842326629,  pressure: 3.300082501351121),
            RawPoint(x: 2.31682016487886,   y:  3.9059039146414882, pressure: 3.2501538559287475),
            RawPoint(x: 2.366580851588986,  y:  4.011427155187248,  pressure: 3.2073339181298968)
        ]
        
        XCTAssertEqual(smoothed, RawInputStabilizer.Smooth(points: rawPoints, radius: 3))
    }
    
    func testRawInputStabilizer_noSmoothing_returnsUnchanged() {
        let stab = RawInputStabilizer(smoothing: 0)
        let expectation = XCTestExpectation()
        
        let rawPoints = RawPoint.generate(n: 100)
        let smoothedStart = rawPoints.reduce(into: []) { $0 += stab.append($1) }
        stab.closeStroke { smoothedEnd in
            XCTAssertEqual(rawPoints, smoothedStart + smoothedEnd)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRawInputStabilizer_manyRadii_returnSmoothedPosition() {
        let rawPoints = RawPoint.generate(n: 50)
        var smoothed = [[RawPoint]]()
        for smoothing in stride(from: 1, to: 20, by: 5) {
            let stab = RawInputStabilizer(smoothing: UInt(smoothing))
            let start = rawPoints.reduce(into: []) { smoothedPoints, rawPoint in
                smoothedPoints += stab.append(rawPoint)
            }
            
            let expectation = XCTestExpectation()
            stab.closeStroke { end in
                smoothed.append(start + end)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.0)
        }
        
        let baseDist = rawPoints.averagePositionDistance
        let distances = smoothed.map { $0.averagePositionDistance }
        let counts = smoothed.map { $0.count }
        XCTAssertEqual(distances, distances.sorted().reversed())
        XCTAssertTrue(distances.allSatisfy { $0 < baseDist })
        XCTAssertTrue(counts.allSatisfy { $0 >= rawPoints.count })
        XCTAssertTrue(distances.reversed().isMonotonic)
    }
    
    func testRawInputStabilizer_manyRadii_returnSmoothedPressure() {
        let rawPoints = RawPoint.generate(n: 50)
        var smoothed = [[RawPoint]]()
        for smoothing in stride(from: 1, to: 20, by: 5) {
            let stab = RawInputStabilizer(smoothing: UInt(smoothing))
            let start = rawPoints.reduce(into: []) { smoothedPoints, rawPoint in
                smoothedPoints += stab.append(rawPoint)
            }
            
            let expectation = XCTestExpectation()
            stab.closeStroke { end in
                smoothed.append(start + end)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.0)
        }
        
        let baseDist = rawPoints.averagePressureDistance
        let distances = smoothed.map { $0.averagePressureDistance }
        XCTAssertEqual(distances, distances.sorted().reversed())
        XCTAssertTrue(distances.allSatisfy { $0 < baseDist })
        XCTAssertTrue(distances.reversed().isMonotonic)
    }
    
    func testRawInputStabilizer_closeWithoutAddingPoints_returnsNoPoint() {
        let stab = RawInputStabilizer(smoothing: 10)
        let expectation = XCTestExpectation()
        stab.closeStroke { points in
            XCTAssertTrue(points.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRawInputStabilizer_appendOnceThenCloseTwice_doesNotCrash() {
        let stab = RawInputStabilizer(smoothing: 10)
        let expect1 = XCTestExpectation()
        _ = stab.append(RawPoint.random)
        stab.closeStroke { points in
            expect1.fulfill()
        }
        
        let expect2 = XCTestExpectation()
        stab.closeStroke { points in
            expect2.fulfill()
        }
        wait(for: [expect1, expect2], timeout: 1.0)
    }
    
    func testRawInputStabilizer_regressionTest() {
        let rawPoints = [
            RawPoint(x:  4.934228003809604,  y: -1.231373934919608,  pressure: 4.53898857886708),
            RawPoint(x:  0.21306836072205293,y: -9.068555432177952,  pressure: 7.538795692618186),
            RawPoint(x: -4.683175482376107,  y: -2.9923432158645706, pressure: 3.6256478458721078),
            RawPoint(x:  5.81296657004669,   y:  6.922822070174725,  pressure: 3.4498860476249673),
            RawPoint(x:  5.081333411540214,  y:  1.5105455201062075, pressure: 9.602908819367713),
            RawPoint(x:  0.930279515561903,  y: -2.2516828057717024, pressure: 1.8050276188190837),
            RawPoint(x:  2.005408030081597,  y:  0.8340246902578645, pressure: 8.668910018412035),
            RawPoint(x: -2.437283687244072,  y:  2.0370835501506352, pressure: 1.5696297734004776),
            RawPoint(x:  4.946506634546136,  y:  5.871941044683169,  pressure: 5.331639210382639),
            RawPoint(x:  2.4019768533874934, y:  4.090560620986006,  pressure: 3.1725691900771804)
        ]
        
        let expectedSmoothed = [
            RawPoint(x:  2.9664847997148267, y: -4.49785119820529,   pressure: 5.928479323027297),
            RawPoint(x:  2.966203230464083,  y: -4.498318606530564,  pressure: 5.928586803108407),
            RawPoint(x:  2.965887600416877,  y: -4.498842556185511,  pressure: 5.92870751890115),
            RawPoint(x:  2.9655515338917953, y: -4.499400430638257,  pressure: 5.9288390788234535),
            RawPoint(x:  2.9652086552074213, y: -4.49996961335694,   pressure: 5.928979091293249),
            RawPoint(x:  2.964872588682339,  y: -4.500527487809687,  pressure: 5.929125164728463),
            RawPoint(x:  2.9645569586351335, y: -4.501051437464633,  pressure: 5.929274907547026),
            RawPoint(x:  2.964275389384389,  y: -4.501518845789907,  pressure: 5.929425928166867),
            RawPoint(x:  2.96404150524869,   y: -4.501907096253643,  pressure: 5.929575835005912),
            RawPoint(x:  2.9668912585525953, y: -4.4971764716712235, pressure: 5.92831363632826),
            RawPoint(x:  2.963868930546621,  y: -4.502193572323974,  pressure: 5.9297222364820925),
            RawPoint(x:  2.960173964127286,  y: -4.50832726079117,   pressure: 5.931478371544193),
            RawPoint(x:  2.9558472629818895, y: -4.515509636462476,  pressure: 5.933590572357341),
            RawPoint(x:  2.9514251198994637, y: -4.522850446891236,  pressure: 5.935842933768271),
            RawPoint(x:  2.9470984187540683, y: -4.530032822562542,  pressure: 5.938195233427811),
            RawPoint(x:  2.949107244285859,  y: -4.526698148143722,  pressure: 5.937257443558562),
            RawPoint(x:  2.945739507364915,  y: -4.532288631728215,  pressure: 5.939356224044476),
            RawPoint(x:  2.9356625542406154, y: -4.549016494487556,  pressure: 5.945272026573869),
            RawPoint(x:  2.917598330921372,  y: -4.579003321339979,  pressure: 5.955790259237506),
            RawPoint(x:  2.891314906324115,  y: -4.622634120658491,  pressure: 5.9711626286356),
            RawPoint(x:  2.856935135032451,  y: -4.67970495236432,   pressure: 5.991513704930739),
            RawPoint(x:  2.827044155571507,  y: -4.729324335921754,  pressure: 6.009279906811767),
            RawPoint(x:  2.7847088460515046, y: -4.799601456276422,  pressure: 6.03463565776168),
            RawPoint(x:  2.728433474460388,  y: -4.888034567096067,  pressure: 6.067146059297639),
            RawPoint(x:  2.643553980824086,  y: -5.006696203411088,  pressure: 6.110057668204926),
            RawPoint(x:  2.5149155540712886, y: -5.160037941705336,  pressure: 6.1623773626456675),
            RawPoint(x:  2.3264000427042038, y: -5.345674903857293,  pressure: 6.219058458193899),
            RawPoint(x:  2.0619592339897728, y: -5.553820811942865,  pressure: 6.271074250061533),
            RawPoint(x:  1.6815648074884764, y: -5.809511974389008,  pressure: 6.321852799586325),
            RawPoint(x:  1.1966680755727734, y: -6.0525664205366,    pressure: 6.3446790608208685),
            RawPoint(x:  0.6313896792103301, y: -6.21990513150897,   pressure: 6.314726988922509),
            RawPoint(x:  0.024479304129594884,y: -6.250959141020067, pressure: 6.212316533815106),
            RawPoint(x: -0.5752319411679929, y: -6.099244729470188,  pressure: 6.028640009369688),
            RawPoint(x: -1.1109651710308535, y: -5.735297222483373,  pressure: 5.76712728189308),
            RawPoint(x: -1.5210270230219731, y: -5.146464061172096,  pressure: 5.442819334521361),
            RawPoint(x: -1.7300230449071226, y: -4.31504271810601,   pressure: 5.072751082754849),
            RawPoint(x: -1.6978475852167427, y: -3.283702672353152,  pressure: 4.695696150620342),
            RawPoint(x: -1.408184706795421,  y: -2.1123497557724615, pressure: 4.354278933853765),
            RawPoint(x: -0.8733314353747346, y: -0.8736517322020476, pressure: 4.090784642478607),
            RawPoint(x: -0.13235432804317324,y:  0.35553817312967406,pressure: 3.941298039438771),
            RawPoint(x:  0.7529599811277028, y:  1.4994550495469983, pressure: 3.9315861533913243),
            RawPoint(x:  1.7040200399528018, y:  2.4860262844414702, pressure: 4.0735327265163965),
            RawPoint(x:  2.6332729860226287, y:  3.252883502589475,  pressure: 4.3617585720099905),
            RawPoint(x:  3.460592523803373,  y:  3.758793877109807,  pressure: 4.7711757028300825),
            RawPoint(x:  4.123778887325358,  y:  3.9866462478002425, pressure: 5.2573254472656),
            RawPoint(x:  4.584129229953266,  y:  3.9439567608189154, pressure: 5.76039085793497),
            RawPoint(x:  4.827511550665848,  y:  3.660079249044572,  pressure: 6.212714773026118),
            RawPoint(x:  4.861101890066424,  y:  3.1812304024537434, pressure: 6.549437745023394),
            RawPoint(x:  4.1917269894538345, y:  1.8875563636415833, pressure: 6.223792044060418),
            RawPoint(x:  3.824246170242803,  y:  1.2003936129414183, pressure: 6.080171167781892),
            RawPoint(x:  3.3889101019956454, y:  0.5575893664329827, pressure: 5.831396310347463),
            RawPoint(x:  2.9389509660831994, y:  0.016232113225300493,pressure: 5.545176770538262),
            RawPoint(x:  2.515572387075908,  y: -0.38623340264291983,pressure: 5.293615125666612),
            RawPoint(x:  2.1471987085078834, y: -0.6299871950720113, pressure: 5.136910654390833),
            RawPoint(x:  1.845525130940751,  y: -0.7132681591746863, pressure: 5.10743619868656),
            RawPoint(x:  1.605015836287207,  y: -0.6512869167386209, pressure: 5.201030543964366),
            RawPoint(x:  1.4054761529321635, y: -0.4709980556121869, pressure: 5.377447732291141),
            RawPoint(x:  1.2193060446790607, y: -0.20398969650952722,pressure: 5.570953698783243),
            RawPoint(x:  1.022463065485723,  y:  0.11770810266959104,pressure: 5.709557102043563),
            RawPoint(x:  0.8026113302303086, y:  0.4678176363280555, pressure: 5.7348346649061614),
            RawPoint(x:  0.5620339822529483, y:  0.8274940608003819, pressure: 5.6151359586551175),
            RawPoint(x:  0.319597756437374,  y:  1.1868695470332347, pressure: 5.3529504519093),
            RawPoint(x:  0.1095539298458843, y:  1.545136280245703,  pressure: 4.984156131176478),
            RawPoint(x: -0.023178353446108406,y: 1.9084814957333212, pressure: 4.568613795943648),
            RawPoint(x: -0.03596646134345747,y:  2.2832951586567884, pressure: 4.174597499339586),
            RawPoint(x:  0.09900234329747254,y:  2.672951840591155,  pressure: 3.8617898875042957),
            RawPoint(x:  0.3875157214737409, y:  3.0746131959753766, pressure: 3.6682884564577614),
            RawPoint(x:  0.8109836660076992, y:  3.478104157878776,  pressure: 3.6044413992028734),
            RawPoint(x:  1.3283897042119002, y:  3.866359023602944,  pressure: 3.6532240075789177),
            RawPoint(x:  1.8824718342941695, y:  4.217448620084521,  pressure: 3.7772110430640615),
            RawPoint(x:  2.4092638930336725, y:  4.50847043392451,   pressure: 3.9293173503826915),
            RawPoint(x:  2.843484017796218,  y:  4.716152945770938,  pressure: 4.057369782984485),
            RawPoint(x:  3.166288914465359,  y:  4.844904836689559,  pressure: 4.1422685502676),
            RawPoint(x:  3.362566051446039,  y:  4.8971437227094965, pressure: 4.1671445252294195),
            RawPoint(x:  3.4375698513749047, y:  4.883535335292599,  pressure: 4.131012483117498),
            RawPoint(x:  3.413803696961431,  y:  4.8213346638935475, pressure: 4.046495303520145),
            RawPoint(x:  3.3243030135128913, y:  4.731292554884586,  pressure: 3.9337390990528647),
            RawPoint(x:  3.204761843287692,  y:  4.633911168326467,  pressure: 3.8146142306106285),
            RawPoint(x:  3.104607458871655,  y:  4.557991662458128,  pressure: 3.722030403559821),
            RawPoint(x:  3.0064269094181393, y:  4.488844757096594,  pressure: 3.638758298085497),
            RawPoint(x:  2.9188234305328713, y:  4.429560272378596,  pressure: 3.5682831818624003),
            RawPoint(x:  2.844373693562577,  y:  4.380192845819018,  pressure: 3.510276913447369),
            RawPoint(x:  2.781767074607247,  y:  4.33905994597344,   pressure: 3.4622134643699964),
            RawPoint(x:  2.727051515641289,  y:  4.303237294461757,  pressure: 3.4204439754115823),
            RawPoint(x:  2.6680968555768447, y:  4.264660187049894,  pressure: 3.375477615815667),
            RawPoint(x:  2.6166843599469263, y:  4.231014736353222,  pressure: 3.3362571691095013),
            RawPoint(x:  2.575412990162508,  y:  4.204012551548772,  pressure: 3.3047855204599337),
            RawPoint(x:  2.5441249836785307, y:  4.1835458463542485, pressure: 3.2809337969719246),
            RawPoint(x:  2.5223244294874068, y:  4.169287236579098,  pressure: 3.264318343790425),
            RawPoint(x:  2.508292454950977,  y:  4.16011058950311,   pressure: 3.2536255312446585),
            RawPoint(x:  2.500304684831655,  y:  4.154887052432684,  pressure: 3.2475391847389066),
            RawPoint(x:  2.5045015854162425, y:  4.157631540474789,  pressure: 3.2507369707145566),
            RawPoint(x:  2.494861242631538,  y:  4.151327361736989,  pressure: 3.2433915169312346),
            RawPoint(x:  2.4852826596978304, y:  4.145063591075834,  pressure: 3.2360931604502357),
            RawPoint(x:  2.4760762746816094, y:  4.13904322669428,   pressure: 3.229078422881634),
            RawPoint(x:  2.468300252622844,  y:  4.133958231600928,  pressure: 3.2231535528409925),
            RawPoint(x:  2.4619901189808915, y:  4.129831832956675,  pressure: 3.2183456109437043),
            RawPoint(x:  2.4505667874358785, y:  4.122361755073936,  pressure: 3.209641729045566),
            RawPoint(x:  2.46110080276788,   y:  4.129250280852016,  pressure: 3.2176680060457907),
            RawPoint(x:  2.460069835606319,  y:  4.128576098748415,  pressure: 3.216882471835179),
            RawPoint(x:  2.4589344899142,    y:  4.127833660253207,  pressure: 3.2160174076099137),
            RawPoint(x:  2.457732038109511,  y:  4.127047338973725,  pressure: 3.215101212668038),
            RawPoint(x:  2.4564997526102426, y:  4.126241508517308,  pressure: 3.214162286307598),
            RawPoint(x:  2.4552749058343846, y:  4.125440542491289,  pressure: 3.213229027826636),
            RawPoint(x:  2.4540947701999256, y:  4.124668814503006,  pressure: 3.2123298365231987),
            RawPoint(x:  2.4529966181248555, y:  4.123950698159794,  pressure: 3.211493111695328),
            RawPoint(x:  2.452017722027165,  y:  4.123310567068987,  pressure: 3.21074725264107),
            RawPoint(x:  2.4511953543248426, y:  4.122772794837924,  pressure: 3.2101206586584676)
        ]
        
        let stab = RawInputStabilizer(smoothing: 3)
        let start = rawPoints.reduce(into: []) { smoothedPoints, rawPoint in
            smoothedPoints += stab.append(rawPoint)
        }
        
        let expectation = XCTestExpectation()
        stab.closeStroke { end in
            let smoothed = start + end
            XCTAssertEqual(expectedSmoothed, smoothed)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // swiftlint:disable:next empty_xctest_method
    static var allTests = [
        ("testSmooth_nullRadius_returnUnchanged", testSmooth_nullRadius_returnUnchanged),
        ("testSmooth_manyRadii_returnSmoothedPosition", testSmooth_manyRadii_returnSmoothedPosition),
        ("testSmooth_manyRadii_returnSmoothedPressure", testSmooth_manyRadii_returnSmoothedPressure),
        ("testSmooth_regressionTest", testSmooth_regressionTest),
        ("testRawInputStabilizer_noSmoothing_returnsUnchanged", testRawInputStabilizer_noSmoothing_returnsUnchanged),
        ("testRawInputStabilizer_manyRadii_returnSmoothedPosition", testRawInputStabilizer_manyRadii_returnSmoothedPosition),
        ("testRawInputStabilizer_manyRadii_returnSmoothedPressure", testRawInputStabilizer_manyRadii_returnSmoothedPressure),
        ("testRawInputStabilizer_regressionTest", testRawInputStabilizer_regressionTest)
    ]
}
