import Foundation

enum CoordinateFormat: String, CaseIterable, Identifiable {
    case dd = "DD"
    case ddm = "DDM"
    case dms = "DMS"
    case utm = "UTM"
    case mgrs = "MGRS"
    case plusCode = "Plus Code"

    var id: String { rawValue }
}
