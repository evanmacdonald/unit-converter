import Foundation
import Observation

@Observable
final class ConverterViewModel {

    var inputText: String = ""
    var detectedFormat: CoordinateFormat?
    var selectedFormat: CoordinateFormat = .dd
    var formatOverridden: Bool = false
    private(set) var formattedInput: String?
    private(set) var outputs: [OutputRow] = []
    private(set) var errorMessage: String?

    struct OutputRow: Identifiable {
        let format: CoordinateFormat
        let value: String
        var id: String { format.id }
    }

    /// Called when the user explicitly picks a format from the dropdown.
    func overrideFormat(_ format: CoordinateFormat) {
        selectedFormat = format
        formatOverridden = true
        if !inputText.isEmpty {
            convert()
        }
    }

    func reset() {
        inputText = ""
        detectedFormat = nil
        selectedFormat = .dd
        formatOverridden = false
        formattedInput = nil
        outputs = []
        errorMessage = nil
    }

    func convert() {
        errorMessage = nil
        formattedInput = nil

        guard !inputText.isEmpty else {
            outputs = []
            detectedFormat = nil
            formatOverridden = false
            return
        }

        // Auto-detect if user hasn't overridden
        if !formatOverridden {
            if let detected = CoordinateFormat.detect(inputText) {
                detectedFormat = detected
                selectedFormat = detected
            } else {
                detectedFormat = nil
                outputs = []
                errorMessage = "Could not detect coordinate format"
                return
            }
        }

        guard let coordinate = selectedFormat.converter.parse(inputText) else {
            outputs = []
            errorMessage = "Invalid \(selectedFormat.rawValue) coordinate"
            return
        }

        // Show the properly formatted version of the input
        formattedInput = selectedFormat.converter.format(coordinate)

        outputs = CoordinateFormat.allCases
            .filter { $0 != selectedFormat }
            .map { OutputRow(format: $0, value: $0.converter.format(coordinate)) }
    }
}
