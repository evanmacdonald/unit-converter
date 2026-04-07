import Foundation

enum CoordinateFormat: String, CaseIterable, Identifiable {
    case dd = "DD"
    case ddm = "DDM"
    case dms = "DMS"
    case utm = "UTM"
    case mgrs = "MGRS"
    case plusCode = "Plus Code"

    var id: String { rawValue }

    var converter: any CoordinateConverter.Type {
        switch self {
        case .dd: DDConverter.self
        case .ddm: DDMConverter.self
        case .dms: DMSConverter.self
        case .utm: UTMConverter.self
        case .mgrs: MGRSConverter.self
        case .plusCode: PlusCodeConverter.self
        }
    }

    /// Try to detect the coordinate format from user input.
    /// Returns the most likely format, or nil if nothing parses.
    /// Priority order resolves ambiguities (e.g. DMS before DDM before DD,
    /// since "50 26 21.07, -114 56 11.65" could match DDM's lenient too).
    static func detect(_ input: String) -> CoordinateFormat? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        // Try distinctive formats first (least ambiguous)
        // Plus Code: has "+" at a specific position
        if PlusCodeConverter.parse(trimmed) != nil { return .plusCode }
        // MGRS: alphanumeric block like 31TDF30959
        if MGRSConverter.parse(trimmed) != nil { return .mgrs }
        // UTM: zone + letter + easting + northing
        if UTMConverter.parse(trimmed) != nil { return .utm }
        // DMS before DDM — DMS has 3 number groups per coordinate, DDM has 2
        if DMSConverter.parse(trimmed) != nil { return .dms }
        // DDM
        if DDMConverter.parse(trimmed) != nil { return .ddm }
        // DD is most lenient (just two numbers with comma)
        if DDConverter.parse(trimmed) != nil { return .dd }

        return nil
    }
}
