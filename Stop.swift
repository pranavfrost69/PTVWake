import Foundation
import CoreLocation

struct Stop: Identifiable, Codable {
    let stop_id: Int
    let stop_name: String
    let stop_latitude: Double?
    let stop_longitude: Double?
    let route_type: Int
    let suburb: String?

    var id: Int { stop_id }
    var coordinate: CLLocationCoordinate2D? {
        if let lat = stop_latitude, let lon = stop_longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
}

struct StopsResponse: Codable {
    let stops: [Stop]
}