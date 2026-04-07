import Foundation
import Observation

@Observable
final class ConverterViewModel {

    var selectedFormat: CoordinateFormat = .dd
    var inputText: String = ""

    struct OutputRow: Identifiable {
        let format: CoordinateFormat
        let value: String
        var id: String { format.id }
    }

    var outputs: [OutputRow] {
        guard !inputText.isEmpty,
              let coordinate = selectedFormat.converter.parse(inputText) else {
            return []
        }
        return CoordinateFormat.allCases
            .filter { $0 != selectedFormat }
            .map { OutputRow(format: $0, value: $0.converter.format(coordinate)) }
    }
}
