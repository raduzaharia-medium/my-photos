import Foundation
import ImageIO

struct GPSLocation {
    static func parse(from props: [CFString: Any]) -> GeoCoordinate? {
        return getLocation(from: props) ?? getLocationFromXMP(props)
    }
    
    private static func getLocation(from props: [CFString: Any])
        -> GeoCoordinate?
    {
        guard let gps = props["{GPS}" as CFString] as? [CFString: Any] else {
            return nil
        }

        func parseDouble(_ value: Any?) -> Double? {
            if let d = value as? Double { return d }
            if let n = value as? NSNumber { return n.doubleValue }
            if let s = value as? String { return Double(s) }
            return nil
        }

        guard
            let rawLat = parseDouble(gps[kCGImagePropertyGPSLatitude]),
            let rawLon = parseDouble(gps[kCGImagePropertyGPSLongitude])
        else {
            return nil
        }

        let latRef = (gps[kCGImagePropertyGPSLatitudeRef] as? String)?
            .uppercased()
        let lonRef = (gps[kCGImagePropertyGPSLongitudeRef] as? String)?
            .uppercased()

        let latitude = (latRef == "S") ? -abs(rawLat) : abs(rawLat)
        let longitude = (lonRef == "W") ? -abs(rawLon) : abs(rawLon)

        return GeoCoordinate(latitude, longitude)
    }
    
    private static func getLocationFromXMP(_ props: [CFString: Any]) -> GeoCoordinate? {
        guard let xmp = props["{XMP}" as CFString] as? [String: Any] else { return nil }

        guard let latStr = xmp["exif:GPSLatitude"] as? String,
              let lonStr = xmp["exif:GPSLongitude"] as? String else {
            return nil
        }

        // Optional refs if present; override hemisphere from the value if provided
        let latRef = (xmp["exif:GPSLatitudeRef"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let lonRef = (xmp["exif:GPSLongitudeRef"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard let lat = parseXMPDMS(latStr, forcedHemisphere: latRef),
              let lon = parseXMPDMS(lonStr, forcedHemisphere: lonRef) else {
            return nil
        }

        return GeoCoordinate(lat, lon)
    }
    
    private static func parseXMPDMS(_ s: String, forcedHemisphere: String?) -> Double? {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)

        // Extract trailing hemisphere letter if present
        let hemisSet = CharacterSet(charactersIn: "NSEWnsew")
        var hemisphereFromValue: String?
        var numericPart = trimmed
        if let last = trimmed.unicodeScalars.last, hemisSet.contains(last) {
            hemisphereFromValue = String(Character(last)).uppercased()
            numericPart = String(trimmed.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let hemisphere = (forcedHemisphere ?? hemisphereFromValue)?.uppercased()

        // Split by comma (ImageIO/ACDSee often uses comma separators)
        let parts: [String] = numericPart.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }

        func toDouble(_ str: String) -> Double? {
            Double(str.replacingOccurrences(of: ",", with: ".")) // just in case of locale
        }

        let deg: Double
        let minutes: Double
        let seconds: Double

        switch parts.count {
        case 1:
            // Decimal degrees
            guard let d = Double(parts[0].replacingOccurrences(of: ",", with: ".")) else { return nil }
            deg = d; minutes = 0; seconds = 0
        case 2:
            guard let d = toDouble(parts[0]), let m = toDouble(parts[1]) else { return nil }
            deg = d; minutes = m; seconds = 0
        case 3:
            guard let d = toDouble(parts[0]), let m = toDouble(parts[1]), let s = toDouble(parts[2]) else { return nil }
            deg = d; minutes = m; seconds = s
        default:
            return nil
        }

        var decimal = abs(deg) + minutes / 60.0 + seconds / 3600.0
        if let h = hemisphere {
            if h == "S" || h == "W" { decimal = -decimal }
        }
        return decimal
    }
}
