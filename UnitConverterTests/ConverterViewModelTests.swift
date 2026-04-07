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

    // MARK: - Conversion from DD

    func testConvertPopulatesOutputsForValidDD() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338, 2.17403"
        sut.convert()

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .dd })
        XCTAssertNil(sut.errorMessage)
    }

    func testDDConvertsToAllOtherFormats() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338, 2.17403"
        sut.convert()

        let formats = Set(sut.outputs.map(\.format))
        XCTAssertTrue(formats.contains(.ddm))
        XCTAssertTrue(formats.contains(.dms))
        XCTAssertTrue(formats.contains(.utm))
        XCTAssertTrue(formats.contains(.mgrs))
        XCTAssertTrue(formats.contains(.plusCode))
    }

    func testDDOutputValuesAreNonEmpty() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338, 2.17403"
        sut.convert()

        for row in sut.outputs {
            XCTAssertFalse(row.value.isEmpty, "\(row.format.rawValue) output should not be empty")
        }
    }

    // MARK: - Conversion from other formats

    func testDDMInput() {
        sut.selectedFormat = .ddm
        sut.inputText = "41°24.2028'N, 2°10.4418'E"
        sut.convert()

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .ddm })
    }

    func testDMSInput() {
        sut.selectedFormat = .dms
        sut.inputText = "41°24'12.17\"N, 2°10'26.51\"E"
        sut.convert()

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .dms })
    }

    func testUTMInput() {
        sut.selectedFormat = .utm
        sut.inputText = "31T 430960 4583867"
        sut.convert()

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .utm })
    }

    func testMGRSInput() {
        sut.selectedFormat = .mgrs
        sut.inputText = "31TDF3095983866"
        sut.convert()

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .mgrs })
    }

    func testPlusCodeInput() {
        sut.selectedFormat = .plusCode
        sut.inputText = "8FWC2345+G9"
        sut.convert()

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .plusCode })
    }

    // MARK: - Invalid Input

    func testErrorMessageForInvalidInput() {
        sut.selectedFormat = .dd
        sut.inputText = "not a coordinate"
        sut.convert()

        XCTAssertTrue(sut.outputs.isEmpty)
        XCTAssertEqual(sut.errorMessage, "Invalid DD coordinate")
    }

    func testErrorMessageForPartialInput() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338"
        sut.convert()

        XCTAssertTrue(sut.outputs.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testConvertEmptyInputClearsOutputsNoError() {
        sut.selectedFormat = .dd
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
        sut.selectedFormat = .dd
        sut.inputText = "bad"
        sut.convert()
        XCTAssertNotNil(sut.errorMessage)

        sut.inputText = "41.40338, 2.17403"
        sut.convert()
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.outputs.count, 5)
    }

    // MARK: - Output Row Identity

    func testOutputRowsHaveUniqueIds() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338, 2.17403"
        sut.convert()

        let ids = sut.outputs.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    // MARK: - Round-trip accuracy

    func testDDRoundTrip() {
        sut.selectedFormat = .dd
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
}
