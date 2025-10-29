import Foundation

struct Departure: Codable, Identifiable {
    let id = UUID()
    let scheduled_departure_utc: String
    let estimated_departure_utc: String?
    let platform_number: String?
    let at_platform: Bool?
    let stop_id: Int
    let route_id: Int
    let direction_id: Int
    let run_id: Int?
}

struct DeparturesResponse: Codable {
    let departures: [Departure]
}