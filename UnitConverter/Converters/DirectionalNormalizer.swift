import Foundation

/// Converts coordinate strings that use N/S/E/W markers into the signed,
/// comma-separated form the lenient DD/DDM/DMS parsers already understand.
///
///   "30 17.11'N 095 28.07'W" → "30 17.11, -95 28.07"
///   "N 30 17.11 W 95 28.07"  → "30 17.11, -95 28.07"
///   "30.285°N 95.467°W"      → "30.285, -95.467"
enum DirectionalNormalizer {
    static func normalize(_ input: String) -> String? {
        let hasLatDir = input.range(of: "[NnSs]", options: .regularExpression) != nil
        let hasLonDir = input.range(of: "[EeWw]", options: .regularExpression) != nil
        guard hasLatDir, hasLonDir else { return nil }

        // Treat the glyphs that commonly decorate directional input as whitespace
        // so the regex only has to deal with digits, dots, letters and spaces.
        // Includes smart-quote and prime variants that iOS auto-substitutes.
        var s = input
        for glyph in ["'", "\u{2019}", "\u{2018}", "\u{2032}",
                      "\"", "\u{201C}", "\u{201D}", "\u{2033}",
                      "°", ","] {
            s = s.replacingOccurrences(of: glyph, with: " ")
        }

        if let r = apply(s, pattern: suffixPattern,
                         latNumsAt: 1, latDirAt: 2, lonNumsAt: 3, lonDirAt: 4) {
            return r
        }
        if let r = apply(s, pattern: prefixPattern,
                         latNumsAt: 2, latDirAt: 1, lonNumsAt: 4, lonDirAt: 3) {
            return r
        }
        return nil
    }

    // "<lat nums> N/S <lon nums> E/W"
    private static let suffixPattern =
        #"(?i)^\s*([\d.\s]+?)\s*([NS])\s+([\d.\s]+?)\s*([EW])\s*$"#

    // "N/S <lat nums> E/W <lon nums>"
    private static let prefixPattern =
        #"(?i)^\s*([NS])\s*([\d.\s]+?)\s+([EW])\s*([\d.\s]+?)\s*$"#

    private static func apply(_ s: String, pattern: String,
                              latNumsAt: Int, latDirAt: Int,
                              lonNumsAt: Int, lonDirAt: Int) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let m = regex.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) else {
            return nil
        }
        func group(_ i: Int) -> String {
            guard let r = Range(m.range(at: i), in: s) else { return "" }
            return String(s[r])
        }
        let latNums = collapse(group(latNumsAt))
        let lonNums = collapse(group(lonNumsAt))
        guard !latNums.isEmpty, !lonNums.isEmpty else { return nil }
        let latSign = group(latDirAt).uppercased() == "S" ? "-" : ""
        let lonSign = group(lonDirAt).uppercased() == "W" ? "-" : ""
        return "\(latSign)\(latNums), \(lonSign)\(lonNums)"
    }

    private static func collapse(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespaces)
         .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }
}
