import Foundation

struct Direction: Identifiable, Codable {
    let direction_id: Int
    let direction_name: String
    let route_id: Int

    var id: Int { direction_id }
}

struct DirectionsResponse: Codable {
    let directions: [Direction]
}