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

    func testOutputsEmptyWhenInputEmpty() {
        XCTAssertTrue(sut.outputs.isEmpty)
    }

    // MARK: - Conversion from DD

    func testOutputsPopulateForValidDDInput() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338, 2.17403"

        let outputs = sut.outputs
        XCTAssertEqual(outputs.count, 5)
        XCTAssertFalse(outputs.contains { $0.format == .dd })
    }

    func testDDConvertsToAllOtherFormats() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338, 2.17403"

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

        for row in sut.outputs {
            XCTAssertFalse(row.value.isEmpty, "\(row.format.rawValue) output should not be empty")
        }
    }

    // MARK: - Conversion from other formats

    func testDDMInput() {
        sut.selectedFormat = .ddm
        sut.inputText = "41°24.2028'N, 2°10.4418'E"

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .ddm })
    }

    func testDMSInput() {
        sut.selectedFormat = .dms
        sut.inputText = "41°24'12.17\"N, 2°10'26.51\"E"

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .dms })
    }

    func testUTMInput() {
        sut.selectedFormat = .utm
        sut.inputText = "31T 430960 4583867"

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .utm })
    }

    func testMGRSInput() {
        sut.selectedFormat = .mgrs
        sut.inputText = "31TDF3095983866"

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .mgrs })
    }

    func testPlusCodeInput() {
        sut.selectedFormat = .plusCode
        sut.inputText = "8FWC2345+G9"

        XCTAssertEqual(sut.outputs.count, 5)
        XCTAssertFalse(sut.outputs.contains { $0.format == .plusCode })
    }

    // MARK: - Invalid Input

    func testOutputsEmptyForInvalidInput() {
        sut.selectedFormat = .dd
        sut.inputText = "not a coordinate"

        XCTAssertTrue(sut.outputs.isEmpty)
    }

    func testOutputsEmptyForPartialInput() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338"

        XCTAssertTrue(sut.outputs.isEmpty)
    }

    // MARK: - Format Switching

    func testChangingFormatRecalculatesOutputs() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338, 2.17403"
        XCTAssertEqual(sut.outputs.count, 5)

        // Switch to DDM — the DD input is no longer valid DDM
        sut.selectedFormat = .ddm
        XCTAssertTrue(sut.outputs.isEmpty)
    }

    // MARK: - Output Row Identity

    func testOutputRowsHaveUniqueIds() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338, 2.17403"

        let ids = sut.outputs.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    // MARK: - Round-trip accuracy

    func testDDRoundTrip() {
        sut.selectedFormat = .dd
        sut.inputText = "41.40338, 2.17403"

        guard let ddmRow = sut.outputs.first(where: { $0.format == .ddm }) else {
            XCTFail("DDM output missing")
            return
        }

        // Parse the DDM output back
        let roundTrip = DDMConverter.parse(ddmRow.value)
        XCTAssertNotNil(roundTrip)
        XCTAssertTrue(roundTrip!.isEqual(to: Coordinate(latitude: 41.40338, longitude: 2.17403), accuracy: 1e-4))
    }
}
