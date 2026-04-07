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
}
