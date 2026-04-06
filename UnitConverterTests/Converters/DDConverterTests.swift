import XCTest
@testable import UnitConverter

final class DDConverterTests: XCTestCase {

    // MARK: - Parsing

    func testParseValidDD() {
        let coord = DDConverter.parse("41.40338, 2.17403")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: 41.40338, longitude: 2.17403)))
    }

    func testParseNegativeValues() {
        let coord = DDConverter.parse("-33.8688, -151.2093")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: -33.8688, longitude: -151.2093)))
    }

    func testParseWithoutSpaceAfterComma() {
        let coord = DDConverter.parse("41.40338,2.17403")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: 41.40338, longitude: 2.17403)))
    }

    func testParseMalformedReturnsNil() {
        XCTAssertNil(DDConverter.parse("not a coordinate"))
        XCTAssertNil(DDConverter.parse("41.40338"))
        XCTAssertNil(DDConverter.parse(""))
    }

    func testParseOutOfRangeReturnsNil() {
        XCTAssertNil(DDConverter.parse("91.0, 0.0"))
        XCTAssertNil(DDConverter.parse("0.0, 181.0"))
    }

    // MARK: - Formatting

    func testFormatCoordinate() {
        let result = DDConverter.format(Coordinate(latitude: 41.40338, longitude: 2.17403))
        XCTAssertEqual(result, "41.403380, 2.174030")
    }

    func testFormatNegativeCoordinate() {
        let result = DDConverter.format(Coordinate(latitude: -33.8688, longitude: -151.2093))
        XCTAssertEqual(result, "-33.868800, -151.209300")
    }

    // MARK: - Round trip

    func testRoundTrip() {
        let original = Coordinate(latitude: 41.40338, longitude: 2.17403)
        let formatted = DDConverter.format(original)
        let parsed = DDConverter.parse(formatted)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(parsed!.isEqual(to: original))
    }
}
