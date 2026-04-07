import Foundation

enum PlusCodeConverter: CoordinateConverter {

    private static let alphabet = Array("23456789CFGHJMPQRVWX")
    private static let base = 20

    // Resolution of each pair (latitude, longitude) for pairs 1-5
    // Pair 1: 180/20 = 9° lat, 360/20 = 18° lon
    // Each subsequent pair divides by 20
    private static let latResolutions: [Double] = [9.0, 0.45, 0.0225, 0.001125, 0.000_056_25]
    private static let lonResolutions: [Double] = [18.0, 0.9, 0.045, 0.002_25, 0.000_112_5]

    static func parse(_ input: String) -> Coordinate? {
        let trimmed = input.trimmingCharacters(in: .whitespaces).uppercased()

        guard let plusIndex = trimmed.firstIndex(of: "+") else {
            return nil
        }

        let charsBeforePlus = trimmed.distance(from: trimmed.startIndex, to: plusIndex)

        // Must have exactly 8 characters before "+"
        guard charsBeforePlus == 8 else {
            return nil
        }

        // Must have even number of characters before "+"
        // (already guaranteed by == 8, but kept for clarity)

        let code = trimmed.replacingOccurrences(of: "+", with: "")

        // Must have at least 8 digits, and even total count
        guard code.count >= 8, code.count % 2 == 0 else {
            return nil
        }

        let chars = Array(code)

        // Validate all characters are in the alphabet
        let charSet = Set(alphabet)
        for ch in chars {
            guard charSet.contains(ch) else {
                return nil
            }
        }

        var lat = 0.0
        var lon = 0.0
        let pairCount = min(chars.count / 2, 5)

        for i in 0..<pairCount {
            guard let latIdx = alphabet.firstIndex(of: chars[i * 2]),
                  let lonIdx = alphabet.firstIndex(of: chars[i * 2 + 1]) else {
                return nil
            }
            lat += Double(latIdx) * latResolutions[i]
            lon += Double(lonIdx) * lonResolutions[i]
        }

        // Add half the resolution of the last decoded pair for center of cell
        let lastPair = pairCount - 1
        lat += latResolutions[lastPair] / 2.0
        lon += lonResolutions[lastPair] / 2.0

        lat -= 90.0
        lon -= 180.0

        guard (-90...90).contains(lat), (-180...180).contains(lon) else {
            return nil
        }

        return Coordinate(latitude: lat, longitude: lon)
    }

    static func format(_ coordinate: Coordinate) -> String {
        // Clamp latitude to [-90, 90) and normalize longitude to [-180, 180)
        var lat = min(max(coordinate.latitude, -90.0), 90.0 - latResolutions[4])
        var lon = coordinate.longitude
        while lon < -180.0 { lon += 360.0 }
        while lon >= 180.0 { lon -= 360.0 }

        // Shift to positive range
        lat += 90.0
        lon += 180.0

        var code = ""
        for i in 0..<5 {
            let latDigit = min(Int(lat / latResolutions[i]), base - 1)
            let lonDigit = min(Int(lon / lonResolutions[i]), base - 1)
            lat -= Double(latDigit) * latResolutions[i]
            lon -= Double(lonDigit) * lonResolutions[i]
            code.append(alphabet[latDigit])
            code.append(alphabet[lonDigit])
            if i == 3 {
                code.append("+")
            }
        }

        return code
    }
}
