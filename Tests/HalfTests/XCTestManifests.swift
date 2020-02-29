#if !canImport(ObjectiveC)
import XCTest

extension HalfCodingTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__HalfCodingTests = [
        ("testEncodingDecoding", testEncodingDecoding),
        ("testThrowingCases", testThrowingCases),
    ]
}

extension HalfTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__HalfTests = [
        ("testAddProduct", testAddProduct),
        ("testBasicComparisons", testBasicComparisons),
        ("testBasicMathematicalFunctions", testBasicMathematicalFunctions),
        ("testBasicValues", testBasicValues),
        ("testBinade", testBinade),
        ("testBitPattern", testBitPattern),
        ("testCanonical", testCanonical),
        ("testConvertFromIntTypes", testConvertFromIntTypes),
        ("testConvertFromOtherFloatTypes", testConvertFromOtherFloatTypes),
        ("testDescription", testDescription),
        ("testExponent", testExponent),
        ("testHashableProtocolMethods", testHashableProtocolMethods),
        ("testLargestNumbers", testLargestNumbers),
        ("testManualFloatingPointInitialization", testManualFloatingPointInitialization),
        ("testNegativeHalfs", testNegativeHalfs),
        ("testNonNumberValues", testNonNumberValues),
        ("testOutputStreamable", testOutputStreamable),
        ("testPi", testPi),
        ("testRemainder", testRemainder),
        ("testRounding", testRounding),
        ("testSignificand", testSignificand),
        ("testSignificandWidth", testSignificandWidth),
        ("testSmallestNumbers", testSmallestNumbers),
        ("testSquareRoot", testSquareRoot),
        ("testStrideableProtocolMethods", testStrideableProtocolMethods),
        ("testTruncatingRemainder", testTruncatingRemainder),
        ("testULP", testULP),
    ]
}

extension TestFunctions {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__TestFunctions = [
        ("testAllFunctions", testAllFunctions),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(HalfCodingTests.__allTests__HalfCodingTests),
        testCase(HalfTests.__allTests__HalfTests),
        testCase(TestFunctions.__allTests__TestFunctions),
    ]
}
#endif
