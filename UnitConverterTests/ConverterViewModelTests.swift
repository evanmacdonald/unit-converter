import XCTest
@testable import UnitConverter

final class ConverterViewModelTests: XCTestCase {

    private var sut: ConverterViewModel!

    override func setUp() {
        super.setUp()
        sut = ConverterViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testDefaultFormatIsDD() {
        XCTAssertEqual(sut.selectedFormat, .dd)
    }

    func testDefaultInputIsEmpty() {
        XCTAssertTrue(sut.inputText.isEmpty)
    }

    func testOutputsEmptyBeforeConvert() {
        XCTAssertTrue(sut.outputs.isEmpty)
    }

    // MARK: - Auto-detection

    func testAutoDetectsDD() {
        sut.inputText = "41.40338, 2.17403"
        sut.convert()

        XCTAssertEqual(sut.detectedFormat, .dd)
        XCTAssertEqual(sut.selectedFormat, .dd)
        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .dd })
        XCTAssertNil(sut.errorMessage)
    }

    func testAutoDetectsDMS() {
        sut.inputText = "41°24'12.17\"N, 2°10'26.51\"E"
        sut.convert()

        XCTAssertEqual(sut.detectedFormat, .dms)
        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .dms })
    }

    func testAutoDetectsLenientDMS() {
        sut.inputText = "50 26 21.0700, -114 56 11.6474"
        sut.convert()

        XCTAssertEqual(sut.detectedFormat, .dms)
        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertNotNil(sut.formattedInput)
    }

    func testAutoDetectsDDM() {
        sut.inputText = "41°24.2028'N, 2°10.4418'E"
        sut.convert()

        XCTAssertEqual(sut.detectedFormat, .ddm)
        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .ddm })
    }

    func testAutoDetectsUTM() {
        sut.inputText = "31T 430960 4583867"
        sut.convert()

        XCTAssertEqual(sut.detectedFormat, .utm)
        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .utm })
    }

    func testAutoDetectsMGRS() {
        sut.inputText = "31TDF3095983866"
        sut.convert()

        XCTAssertEqual(sut.detectedFormat, .mgrs)
        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .mgrs })
    }

    func testAutoDetectsPlusCode() {
        sut.inputText = "8FWC2345+G9"
        sut.convert()

        XCTAssertEqual(sut.detectedFormat, .plusCode)
        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .plusCode })
    }

    // MARK: - Format Override

    func testOverrideFormatChangesSelectedFormat() {
        sut.inputText = "41.40338, 2.17403"
        sut.convert()
        XCTAssertEqual(sut.detectedFormat, .dd)

        sut.overrideFormat(.ddm)
        XCTAssertEqual(sut.selectedFormat, .ddm)
        XCTAssertTrue(sut.formatOverridden)
    }

    // MARK: - Formatted Input

    func testFormattedInputShownAfterConvert() {
        sut.inputText = "50 26 21.0700, -114 56 11.6474"
        sut.convert()

        XCTAssertNotNil(sut.formattedInput)
        // Should contain degree symbols in properly formatted DMS
        XCTAssertTrue(sut.formattedInput!.contains("°"))
    }

    // MARK: - All Output Formats Non-Empty

    func testOutputValuesAreNonEmpty() {
        sut.inputText = "41.40338, 2.17403"
        sut.convert()

        for row in sut.outputs {
            XCTAssertFalse(row.value.isEmpty, "\(row.format.rawValue) output should not be empty")
        }
    }

    func testAllFormatsPresent() {
        sut.inputText = "41.40338, 2.17403"
        sut.convert()

        let formats = Set(sut.outputs.map(\.format))
        XCTAssertTrue(formats.contains(.ddm))
        XCTAssertTrue(formats.contains(.dms))
        XCTAssertTrue(formats.contains(.utm))
        XCTAssertTrue(formats.contains(.mgrs))
        XCTAssertTrue(formats.contains(.plusCode))
    }

    // MARK: - Invalid Input

    func testErrorMessageForInvalidInput() {
        sut.inputText = "not a coordinate"
        sut.convert()

        XCTAssertTrue(sut.outputs.isEmpty)
        XCTAssertEqual(sut.errorMessage, "Could not detect coordinate format")
    }

    func testErrorMessageForPartialInput() {
        sut.inputText = "41.40338"
        sut.convert()

        XCTAssertTrue(sut.outputs.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testConvertEmptyInputClearsOutputsNoError() {
        sut.inputText = "41.40338, 2.17403"
        sut.convert()
        XCTAssertEqual(sut.outputs.count, 5)

        sut.inputText = ""
        sut.convert()
        XCTAssertTrue(sut.outputs.isEmpty)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Error clears on valid convert

    func testErrorClearsOnValidConvert() {
        sut.inputText = "bad"
        sut.convert()
        XCTAssertNotNil(sut.errorMessage)

        sut.inputText = "41.40338, 2.17403"
        sut.formatOverridden = false
        sut.convert()
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.outputs.count, 5)
    }

    // MARK: - Output Row Identity

    func testOutputRowsHaveUniqueIds() {
        sut.inputText = "41.40338, 2.17403"
        sut.convert()

        let ids = sut.outputs.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    // MARK: - Round-trip accuracy

    func testDDRoundTrip() {
        sut.inputText = "41.40338, 2.17403"
        sut.convert()

        guard let ddmRow = sut.outputs.first(where: { $0.format == .ddm }) else {
            XCTFail("DDM output missing")
            return
        }

        let roundTrip = DDMConverter.parse(ddmRow.value)
        XCTAssertNotNil(roundTrip)
        XCTAssertTrue(roundTrip!.isEqual(to: Coordinate(latitude: 41.40338, longitude: 2.17403), accuracy: 1e-4))
    }

    // MARK: - Convert button resets override

    func testConvertButtonResetsOverride() {
        sut.inputText = "41.40338, 2.17403"
        sut.convert()
        XCTAssertEqual(sut.detectedFormat, .dd)

        sut.overrideFormat(.ddm)
        XCTAssertTrue(sut.formatOverridden)

        // Simulate Convert button: reset override, then convert
        sut.formatOverridden = false
        sut.convert()
        XCTAssertEqual(sut.detectedFormat, .dd)
        XCTAssertFalse(sut.formatOverridden)
    }
}
