import Foundation
import Combine
import MapKit

@MainActor
final class MainViewModel: ObservableObject {
    // User selections
    @Published var transportType: Int? // 0: Train, 1: Tram, 2: Bus
    @Published var routes: [Route] = []
    @Published var selectedRoute: Route?
    @Published var directions: [Direction] = []
    @Published var selectedDirection: Direction?
    @Published var stops: [Stop] = []
    @Published var selectedStop: Stop?
    @Published var customGPSPoint: CLLocationCoordinate2D?
    @Published var alarmMode: AlarmMode = .oneStopBefore
    @Published var alarmDistance: Double = 500 // meters
    @Published var departures: [Departure] = []

    @Published var isAlarmSet: Bool = false
    @Published var showMapPicker: Bool = false
    @Published var loading: Bool = false
    @Published var errorMessage: String?

    enum AlarmMode: String, CaseIterable, Identifiable {
        case oneStopBefore, twoStopsBefore, byDistance
        var id: String { rawValue }
        var description: String {
            switch self {
            case .oneStopBefore: return "1 stop before"
            case .twoStopsBefore: return "2 stops before"
            case .byDistance: return "By distance"
            }
        }
    }

    // MARK: - API loading

    func loadRoutes() async {
        guard let type = transportType else { return }
        loading = true
        do {
            routes = try await PTVAPIService.shared.fetchRoutes(for: type)
        } catch {
            errorMessage = "Failed to load routes"
        }
        loading = false
    }

    func loadDirections() async {
        guard let route = selectedRoute else { return }
        loading = true
        do {
            directions = try await PTVAPIService.shared.fetchDirections(routeId: route.route_id)
        } catch {
            errorMessage = "Failed to load directions"
        }
        loading = false
    }

    func loadStops() async {
        guard let route = selectedRoute else { return }
        loading = true
        do {
            stops = try await PTVAPIService.shared.fetchStops(routeId: route.route_id, routeType: route.route_type)
        } catch {
            errorMessage = "Failed to load stops"
        }
        loading = false
    }

    func loadDepartures() async {
        guard let route = selectedRoute, let stop = selectedStop, let direction = selectedDirection else { return }
        loading = true
        do {
            departures = try await PTVAPIService.shared.fetchDepartures(routeId: route.route_id, stopId: stop.stop_id, directionId: direction.direction_id)
        } catch {
            errorMessage = "Failed to load departures"
        }
        loading = false
    }

    // MARK: - Alarm

    func setAlarm(onAlarm: @escaping () -> Void) {
        guard let dest = alarmTargetCoordinate() else { return }
        let radius: Double
        switch alarmMode {
        case .oneStopBefore, .twoStopsBefore:
            radius = 200 // meters; could be smarter by calculating previous stop
        case .byDistance:
            radius = alarmDistance
        }
        LocationService.shared.setGeofence(center: dest, radius: radius, identifier: "ptvWakeAlarm", onAlarm: onAlarm)
        isAlarmSet = true
    }

    func alarmTargetCoordinate() -> CLLocationCoordinate2D? {
        if let custom = customGPSPoint {
            return custom
        } else {
            return selectedStop?.coordinate
        }
    }

    func clearAlarm() {
        LocationService.shared.removeGeofence()
        isAlarmSet = false
    }
}