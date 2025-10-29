# PTV Wake

Wake up before your stop on any Melbourne public transport route with real-time data from PTV.

- iOS 26+, Swift 6, Xcode 16+
- Secure HMAC-SHA1 signing for all PTV API requests
- Dynamic UI, background geofencing, CoreLocation, local notifications
- No analytics. OAIC & Apple privacy compliant.

**Setup:**  
1. Open in Xcode 16+.  
2. Add your PTV API key/developer ID to `Config.swift` if needed.  
3. Enable Background Modes: Location updates & Notifications in project settings.

---

## Project structure

- `Models/`: Codable types for routes, stops, departures...
- `Services/`: PTV API client, Location manager
- `ViewModels/`: All app state
- `Views/`: SwiftUI screens
- `Utils/`: HMAC signature, helpers

---

## Privacy

PTV Wake never collects or shares your data. Location is used _only_ for alarms, with explicit consent.

---

## API Reference

- [PTV Timetable API v3 docs](https://www.ptv.vic.gov.au/footer/data-and-reporting/datasets/ptv-timetable-api/)

---

## License

MIT