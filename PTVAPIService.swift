import Foundation

final class PTVAPIService {
    static let shared = PTVAPIService()

    private init() {}

    // MARK: - URL construction and signing

    private func signedURL(path: String, params: [String: String] = [:]) -> URL? {
        var pathWithParams = path
        var queryItems = params.map { "\($0.key)=\($0.value)" }
        queryItems.append("devid=\(Config.ptvDeveloperID)")
        let query = queryItems.sorted().joined(separator: "&")
        let fullPath = "\(path)?\(query)"
        let signature = HMAC.sign(path: fullPath, key: Config.ptvAPIKey)
        let urlString = "\(Config.ptvBaseURL)\(path)?\(query)&signature=\(signature)"
        return URL(string: urlString)
    }

    // MARK: - Public API

    func fetchRoutes(for type: Int) async throws -> [Route] {
        guard let url = signedURL(path: "/v3/routes", params: ["route_types": "\(type)"]) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(RoutesResponse.self, from: data)
        return decoded.routes
    }

    func fetchDirections(routeId: Int) async throws -> [Direction] {
        guard let url = signedURL(path: "/v3/directions/route/\(routeId)") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(DirectionsResponse.self, from: data)
        return decoded.directions
    }

    func fetchStops(routeId: Int, routeType: Int) async throws -> [Stop] {
        guard let url = signedURL(path: "/v3/stops/route/\(routeId)/route_type/\(routeType)") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(StopsResponse.self, from: data)
        return decoded.stops
    }

    func fetchDepartures(routeId: Int, stopId: Int, directionId: Int?, maxResults: Int = 5) async throws -> [Departure] {
        var params: [String: String] = [
            "route_id": "\(routeId)",
            "max_results": "\(maxResults)"
        ]
        if let directionId = directionId {
            params["direction_id"] = "\(directionId)"
        }
        guard let url = signedURL(path: "/v3/departures/route_type/0/stop/\(stopId)", params: params) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(DeparturesResponse.self, from: data)
        return decoded.departures
    }
}