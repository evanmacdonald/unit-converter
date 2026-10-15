import XCTest
@testable import UnitConverter

final class DirectionalNormalizerTests: XCTestCase {

    func testDDMSuffixWithApostrophe() {
        XCTAssertEqual(
            DirectionalNormalizer.normalize("30 17.11'N 095 28.07'W"),
            "30 17.11, -095 28.07"
        )
    }

    func testDDMSuffixWithDegreeSymbol() {
        XCTAssertEqual(
            DirectionalNormalizer.normalize("30° 17.11'N 95° 28.07'W"),
            "30 17.11, -95 28.07"
        )
    }

    func testDDMPrefix() {
        XCTAssertEqual(
            DirectionalNormalizer.normalize("N 30 17.11 W 95 28.07"),
            "30 17.11, -95 28.07"
        )
    }

    func testDMSSuffix() {
        XCTAssertEqual(
            DirectionalNormalizer.normalize("30 17 06.6\"N 95 28 04.2\"W"),
            "30 17 06.6, -95 28 04.2"
        )
    }

    func testDDDirectionalNoSpace() {
        XCTAssertEqual(
            DirectionalNormalizer.normalize("30.285N 95.467W"),
            "30.285, -95.467"
        )
    }

    func testSouthEastSigns() {
        XCTAssertEqual(
            DirectionalNormalizer.normalize("33 52.128'S 151 12.558'E"),
            "-33 52.128, 151 12.558"
        )
    }

    // iOS auto-substitutes straight apostrophes to U+2019 (right single quote)
    // when smart punctuation is on, which is the default in SwiftUI TextFields.
    func testSmartQuoteApostrophe() {
        XCTAssertEqual(
            DirectionalNormalizer.normalize("30 17.11\u{2019}N 095 28.07\u{2019}W"),
            "30 17.11, -095 28.07"
        )
    }

    func testSmartQuoteDoubleQuote() {
        XCTAssertEqual(
            DirectionalNormalizer.normalize("30 17 06.6\u{201D}N 95 28 04.2\u{201D}W"),
            "30 17 06.6, -95 28 04.2"
        )
    }

    func testLowercaseDirections() {
        XCTAssertEqual(
            DirectionalNormalizer.normalize("30 17.11'n 095 28.07'w"),
            "30 17.11, -095 28.07"
        )
    }

    func testReturnsNilWithoutDirectionalMarkers() {
        XCTAssertNil(DirectionalNormalizer.normalize("30.285, -95.467"))
        XCTAssertNil(DirectionalNormalizer.normalize("50 26.35, -114 56.19"))
    }

    func testReturnsNilWithOnlyOneAxisMarked() {
        XCTAssertNil(DirectionalNormalizer.normalize("30.285N 95.467"))
        XCTAssertNil(DirectionalNormalizer.normalize("30.285 95.467W"))
    }
}
