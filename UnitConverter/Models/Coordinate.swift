import Foundation

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double

    func isEqual(to other: Coordinate, accuracy: Double = 1e-6) -> Bool {
        abs(latitude - other.latitude) < accuracy &&
        abs(longitude - other.longitude) < accuracy
    }
}
