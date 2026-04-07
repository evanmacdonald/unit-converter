import Foundation
import Observation

@Observable
final class ConverterViewModel {

    var selectedFormat: CoordinateFormat = .dd
    var inputText: String = ""
    private(set) var outputs: [OutputRow] = []
    private(set) var errorMessage: String?

    struct OutputRow: Identifiable {
        let format: CoordinateFormat
        let value: String
        var id: String { format.id }
    }

    func convert() {
        errorMessage = nil
        guard !inputText.isEmpty else {
            outputs = []
            return
        }
        guard let coordinate = selectedFormat.converter.parse(inputText) else {
            outputs = []
            errorMessage = "Invalid \(selectedFormat.rawValue) coordinate"
            return
        }
        outputs = CoordinateFormat.allCases
            .filter { $0 != selectedFormat }
            .map { OutputRow(format: $0, value: $0.converter.format(coordinate)) }
    }
}
