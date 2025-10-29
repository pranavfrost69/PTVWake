import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var vm = MainViewModel()
    @ObservedObject private var locationService = LocationService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    card {
                        transportPicker
                    }
                    if !vm.routes.isEmpty {
                        card {
                            routePicker
                        }
                    }
                    if !vm.directions.isEmpty {
                        card {
                            directionPicker
                        }
                    }
                    if !vm.stops.isEmpty {
                        card {
                            stopPicker
                        }
                    }
                    card {
                        alarmOptions
                    }
                    if let stop = vm.selectedStop {
                        card {
                            routeDetails(stop: stop)
                        }
                    }
                    if vm.showMapPicker {
                        MapPickerView(selectedCoordinate: $vm.customGPSPoint)
                            .frame(height: 300)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("PTV Wake")
            .background(.ultraThinMaterial)
            .alert(item: $vm.errorMessage) { msg in
                Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
            }
            .overlay(alarmStatusBar, alignment: .bottom)
            .onChange(of: vm.transportType) { _ in Task { await vm.loadRoutes() } }
            .onChange(of: vm.selectedRoute) { _ in Task { await vm.loadDirections(); await vm.loadStops() } }
            .onChange(of: vm.selectedDirection) { _ in Task { await vm.loadDepartures() } }
        }
        .task {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .criticalAlert]) { _, _ in }
            locationService.requestAuthorization()
        }
    }

    // MARK: - Card

    @ViewBuilder func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(radius: 8)
            content().padding()
        }
        .padding(.horizontal)
        .animation(.spring, value: vm.loading)
    }

    // MARK: - Pickers

    var transportPicker: some View {
        Picker("Transport", selection: $vm.transportType) {
            Text("Train").tag(0 as Int?)
            Text("Tram").tag(1 as Int?)
            Text("Bus").tag(2 as Int?)
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Choose transport mode")
    }

    var routePicker: some View {
        VStack(alignment: .leading) {
            Text("Route / Line")
                .font(.headline)
            Picker("Route", selection: $vm.selectedRoute) {
                ForEach(vm.routes) { route in
                    Text(route.route_name)
                        .tag(route as Route?)
                }
            }
            .pickerStyle(.menu)
        }
    }

    var directionPicker: some View {
        VStack(alignment: .leading) {
            Text("Direction")
                .font(.headline)
            Picker("Direction", selection: $vm.selectedDirection) {
                ForEach(vm.directions) { dir in
                    Text(dir.direction_name)
                        .tag(dir as Direction?)
                }
            }
            .pickerStyle(.menu)
        }
    }

    var stopPicker: some View {
        VStack(alignment: .leading) {
            Text("Stop")
                .font(.headline)
            Picker("Stop", selection: $vm.selectedStop) {
                ForEach(vm.stops) { stop in
                    Text(stop.stop_name)
                        .tag(stop as Stop?)
                }
            }
            .pickerStyle(.menu)
            Button {
                vm.showMapPicker.toggle()
            } label: {
                Label("Pick GPS point on map", systemImage: "mappin.and.ellipse")
            }
            .buttonStyle(.bordered)
            .foregroundColor(.accentColor)
        }
    }

    var alarmOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Alarm")
                .font(.headline)
            Picker("", selection: $vm.alarmMode) {
                ForEach(MainViewModel.AlarmMode.allCases) { mode in
                    Text(mode.description).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            if vm.alarmMode == .byDistance {
                HStack {
                    Text("Distance: \(Int(vm.alarmDistance)) m")
                    Slider(value: $vm.alarmDistance, in: 100...2000, step: 50)
                }
            }
            Button {
                if !vm.isAlarmSet {
                    vm.setAlarm {
                        vm.isAlarmSet = false
                        vm.errorMessage = "Alarm triggered! Approaching destination."
                    }
                } else {
                    vm.clearAlarm()
                }
            } label: {
                Label(vm.isAlarmSet ? "Cancel Alarm" : "Set Alarm", systemImage: vm.isAlarmSet ? "bell.slash" : "bell.fill")
                    .font(.title2.bold())
            }
            .buttonStyle(.borderedProminent)
            .tint(vm.isAlarmSet ? .red : .accentColor)
        }
    }

    func routeDetails(stop: Stop) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next Departures for \(stop.stop_name)")
                .font(.title3.bold())
            if vm.departures.isEmpty {
                ProgressView().padding()
            } else {
                ForEach(vm.departures) { dep in
                    DepartureRow(departure: dep)
                }
            }
        }
    }

    var alarmStatusBar: some View {
        VStack {
            if vm.isAlarmSet {
                HStack {
                    Image(systemName: "alarm")
                    Text("Alarm set. We'll wake you before your stop.")
                        .font(.callout)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .transition(.move(edge: .bottom))
            }
        }
    }
}

struct DepartureRow: View {
    let departure: Departure

    var body: some View {
        let date = ISO8601DateFormatter().date(from: departure.estimated_departure_utc ?? departure.scheduled_departure_utc) ?? Date()
        HStack {
            Image(systemName: "tram.fill")
                .foregroundColor(.accentColor)
            VStack(alignment: .leading) {
                Text(date, style: .time)
                    .font(.title3.bold())
                if let plat = departure.platform_number {
                    Text("Platform \(plat)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if (departure.at_platform ?? false) {
                Text("At platform")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 2)
    }
}