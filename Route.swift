import Foundation

struct Route: Identifiable, Codable {
    let route_id: Int
    let route_name: String
    let route_number: String?
    let route_type: Int

    var id: Int { route_id }
}

struct RoutesResponse: Codable {
    let routes: [Route]
}