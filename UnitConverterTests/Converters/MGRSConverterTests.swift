import XCTest
@testable import UnitConverter

final class MGRSConverterTests: XCTestCase {

    // MARK: - Parsing

    func testParseNorthernHemisphere() {
        // Barcelona: 41.40338 N, 2.17403 E -> 31T CF 30959 84041
        let coord = MGRSConverter.parse("31TCF3095984041")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: 41.40338, longitude: 2.17403), accuracy: 1e-3))
    }

    func testParseWithSpaces() {
        let coord = MGRSConverter.parse("31T CF 30959 84041")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: 41.40338, longitude: 2.17403), accuracy: 1e-3))
    }

    func testParseSouthernHemisphere() {
        // Sydney: -33.8688 S, 151.2093 E -> 56H LH 34786 51080
        let coord = MGRSConverter.parse("56HLH3478651080")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: -33.8688, longitude: 151.2093), accuracy: 1e-3))
    }

    func testParseWesternHemisphere() {
        // New York: 40.7128 N, -74.0060 W -> 18T WL 83960 07523
        let coord = MGRSConverter.parse("18TWL8396007523")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: 40.7128, longitude: -74.0060), accuracy: 1e-3))
    }

    func testParseMalformedReturnsNil() {
        XCTAssertNil(MGRSConverter.parse("not a coordinate"))
        XCTAssertNil(MGRSConverter.parse(""))
        XCTAssertNil(MGRSConverter.parse("99TCF3095984041")) // invalid zone
    }

    func testParseLowerCase() {
        let coord = MGRSConverter.parse("31tcf3095984041")
        XCTAssertNotNil(coord)
        XCTAssertTrue(coord!.isEqual(to: Coordinate(latitude: 41.40338, longitude: 2.17403), accuracy: 1e-3))
    }

    // MARK: - Formatting

    func testFormatNorthernHemisphere() {
        let result = MGRSConverter.format(Coordinate(latitude: 41.40338, longitude: 2.17403))
        XCTAssertTrue(result.hasPrefix("31T"))
        XCTAssertTrue(result.contains("CF"))
    }

    func testFormatSouthernHemisphere() {
        let result = MGRSConverter.format(Coordinate(latitude: -33.8688, longitude: 151.2093))
        XCTAssertTrue(result.hasPrefix("56H"))
    }

    // MARK: - Round trip

    func testRoundTrip() {
        let original = Coordinate(latitude: 41.40338, longitude: 2.17403)
        let formatted = MGRSConverter.format(original)
        let parsed = MGRSConverter.parse(formatted)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(parsed!.isEqual(to: original, accuracy: 1e-3))
    }

    func testRoundTripSouthernHemisphere() {
        let original = Coordinate(latitude: -33.8688, longitude: 151.2093)
        let formatted = MGRSConverter.format(original)
        let parsed = MGRSConverter.parse(formatted)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(parsed!.isEqual(to: original, accuracy: 1e-3))
    }

    func testRoundTripWesternHemisphere() {
        let original = Coordinate(latitude: 40.7128, longitude: -74.0060)
        let formatted = MGRSConverter.format(original)
        let parsed = MGRSConverter.parse(formatted)
        XCTAssertNotNil(parsed)
        XCTAssertTrue(parsed!.isEqual(to: original, accuracy: 1e-3))
    }
}
