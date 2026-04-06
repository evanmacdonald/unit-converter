import XCTest
@testable import UnitConverter

final class UTMConverterTests: XCTestCase {

    // MARK: - Parsing

    func testParseNorthernHemisphere() {
        // Barcelona: 41.40338 N, 2.17403 E
        let coord = UTMConverter.parse("31T 430960 4583867")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: 41.40338, longitude: 2.17403), accuracy: 1e-3))
    }

    func testParseSouthernHemisphere() {
        // Sydney: -33.8688 S, 151.2093 E
        let coord = UTMConverter.parse("56H 334369 6250948")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: -33.8688, longitude: 151.2093), accuracy: 1e-3))
    }

    func testParseWesternHemisphere() {
        // New York: 40.7128 N, -74.0060 W
        let coord = UTMConverter.parse("18T 583959 4507351")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: 40.7128, longitude: -74.0060), accuracy: 1e-3))
    }

    func testParseEquator() {
        // Point on equator: 0.0, 39.0 (central meridian of zone 37) -> 37N 500000 0
        let coord = UTMConverter.parse("37N 500000 0")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: 0.0, longitude: 39.0), accuracy: 1e-3))
    }

    func testParseMalformedReturnsNil() {
        XCTAssertNil(UTMConverter.parse("not a coordinate"))
        XCTAssertNil(UTMConverter.parse(""))
        XCTAssertNil(UTMConverter.parse("99T 500000 5000000")) // invalid zone
        XCTAssertNil(UTMConverter.parse("31I 500000 5000000")) // I not valid letter
        XCTAssertNil(UTMConverter.parse("31O 500000 5000000")) // O not valid letter
    }

    // MARK: - Formatting

    func testFormatNorthernHemisphere() {
        let result = UTMConverter.format(Coordinate(latitude: 41.40338, longitude: 2.17403))
        XCTAssertTrue(result.hasPrefix("31T"))
        // Verify round-trip accuracy by parsing the result
        let parsed = UTMConverter.parse(result)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(parsed!.isEqual(to: Coordinate(latitude: 41.40338, longitude: 2.17403), accuracy: 1e-3))
    }

    func testFormatSouthernHemisphere() {
        let result = UTMConverter.format(Coordinate(latitude: -33.8688, longitude: 151.2093))
        XCTAssertTrue(result.hasPrefix("56H"))
        let parsed = UTMConverter.parse(result)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(parsed!.isEqual(to: Coordinate(latitude: -33.8688, longitude: 151.2093), accuracy: 1e-3))
    }

    func testFormatWesternHemisphere() {
        let result = UTMConverter.format(Coordinate(latitude: 40.7128, longitude: -74.0060))
        XCTAssertTrue(result.hasPrefix("18T"))
    }

    // MARK: - Round trip

    func testRoundTrip() {
        let original = Coordinate(latitude: 41.40338, longitude: 2.17403)
        let formatted = UTMConverter.format(original)
        let parsed = UTMConverter.parse(formatted)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(parsed!.isEqual(to: original, accuracy: 1e-3))
    }

    func testRoundTripNegativeCoordinates() {
        let original = Coordinate(latitude: -33.8688, longitude: -151.2093)
        let formatted = UTMConverter.format(original)
        let parsed = UTMConverter.parse(formatted)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(parsed!.isEqual(to: original, accuracy: 1e-3))
    }
}
