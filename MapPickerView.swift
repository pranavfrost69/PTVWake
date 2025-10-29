import SwiftUI
import MapKit

struct MapPickerView: View {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @State private var region: MKCoordinateRegion

    init(selectedCoordinate: Binding<CLLocationCoordinate2D?>) {
        _selectedCoordinate = selectedCoordinate
        let initial = selectedCoordinate.wrappedValue ?? CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631)
        _region = State(initialValue: MKCoordinateRegion(center: initial, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, annotationItems: annotationItems) { item in
                MapMarker(coordinate: item.coordinate, tint: .accentColor)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .onTapGesture { location in
                let coord = region.center
                selectedCoordinate = coord
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        selectedCoordinate = region.center
                    } label: {
                        Label("Pick Here", systemImage: "mappin.and.ellipse")
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding()
                }
            }
        }
    }

    private var annotationItems: [AnnotationItem] {
        if let selected = selectedCoordinate {
            return [AnnotationItem(coordinate: selected)]
        } else {
            return []
        }
    }

    struct AnnotationItem: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
}