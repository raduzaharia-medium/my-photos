import Foundation
import ImageIO

struct GpsProps {
    private var gpsKey: CFString { kCGImagePropertyGPSDictionary }

    private var gpsLatKey: CFString { kCGImagePropertyGPSLatitude }
    private var gpsLatRefKey: CFString { kCGImagePropertyGPSLatitudeRef }
    private var gpsLonKey: CFString { kCGImagePropertyGPSLongitude }
    private var gpsLonRefKey: CFString { kCGImagePropertyGPSLongitudeRef }

    private let props: [CFString: Any]

    init(_ props: [CFString: Any]) {
        self.props = props
    }

    var gps: [CFString: Any]? { props[gpsKey] as? [CFString: Any] }

    var location: GeoCoordinate? {
        guard let gpsLat = parseDouble(gps?[gpsLatKey]) else { return nil }
        guard let gpsLatRef = gps?[gpsLatRefKey] as? String else { return nil }
        guard let gpsLon = parseDouble(gps?[gpsLonKey]) else { return nil }
        guard let gpsLonRef = gps?[gpsLonRefKey] as? String else { return nil }

        let lat = (gpsLatRef.uppercased() == "S") ? -abs(gpsLat) : abs(gpsLat)
        let lon = (gpsLonRef.uppercased() == "W") ? -abs(gpsLon) : abs(gpsLon)

        return GeoCoordinate(lat, lon)
    }

    private func parseDouble(_ value: Any?) -> Double? {
        if let d = value as? Double { return d }
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String { return Double(s) }

        return nil
    }
}
