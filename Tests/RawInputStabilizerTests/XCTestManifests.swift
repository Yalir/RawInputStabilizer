import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(RawInputStabilizerTests.allTests),
        testCase(CatmullRomTests.allTests)
    ]
}
#endif
