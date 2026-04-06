import Foundation

enum DMSConverter: CoordinateConverter {
    static func parse(_ input: String) -> Coordinate? {
        let pattern = #"(\d+)\s*°\s*(\d+)\s*'\s*(\d+\.?\d*)\s*"\s*([NSns])\s*,\s*(\d+)\s*°\s*(\d+)\s*'\s*(\d+\.?\d*)\s*"\s*([EWew])"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) else {
            return nil
        }

        func group(_ i: Int) -> String {
            let range = Range(match.range(at: i), in: input)!
            return String(input[range])
        }

        guard let latDeg = Double(group(1)),
              let latMin = Double(group(2)),
              let latSec = Double(group(3)),
              let lonDeg = Double(group(5)),
              let lonMin = Double(group(6)),
              let lonSec = Double(group(7)) else {
            return nil
        }

        var lat = latDeg + latMin / 60.0 + latSec / 3600.0
        var lon = lonDeg + lonMin / 60.0 + lonSec / 3600.0

        if group(4).uppercased() == "S" { lat = -lat }
        if group(8).uppercased() == "W" { lon = -lon }

        guard (-90...90).contains(lat), (-180...180).contains(lon) else {
            return nil
        }

        return Coordinate(latitude: lat, longitude: lon)
    }

    static func format(_ coordinate: Coordinate) -> String {
        let latDir = coordinate.latitude >= 0 ? "N" : "S"
        let lonDir = coordinate.longitude >= 0 ? "E" : "W"

        let absLat = abs(coordinate.latitude)
        let absLon = abs(coordinate.longitude)

        let latDeg = Int(absLat)
        let latMinFull = (absLat - Double(latDeg)) * 60.0
        let latMin = Int(latMinFull)
        let latSec = (latMinFull - Double(latMin)) * 60.0

        let lonDeg = Int(absLon)
        let lonMinFull = (absLon - Double(lonDeg)) * 60.0
        let lonMin = Int(lonMinFull)
        let lonSec = (lonMinFull - Double(lonMin)) * 60.0

        return String(format: "%d°%d'%.2f\"%@, %d°%d'%.2f\"%@",
                       latDeg, latMin, latSec, latDir,
                       lonDeg, lonMin, lonSec, lonDir)
    }
}
