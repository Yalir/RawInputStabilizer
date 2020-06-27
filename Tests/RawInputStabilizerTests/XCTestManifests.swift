import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RawInputStabilizerTests.allTests),
        testCase(CatmullRomTests.allTests)
    ]
}
#endif
