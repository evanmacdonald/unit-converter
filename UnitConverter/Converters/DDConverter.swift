import Foundation

enum DDConverter: CoordinateConverter {
    static func parse(_ input: String) -> Coordinate? {
        let parts = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2,
              let lat = Double(parts[0]),
              let lon = Double(parts[1]) else {
            return nil
        }
        guard (-90...90).contains(lat), (-180...180).contains(lon) else {
            return nil
        }
        return Coordinate(latitude: lat, longitude: lon)
    }

    static func format(_ coordinate: Coordinate) -> String {
        String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
    }
}
