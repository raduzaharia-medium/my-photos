import Foundation
import ImageIO

struct ImageProps {
    private var exifKey: CFString { kCGImagePropertyExifDictionary }
    private var tiffKey: CFString { kCGImagePropertyTIFFDictionary }
    private var iptcKey: CFString { "{IPTC}" as CFString }
    private var gpsKey: CFString { kCGImagePropertyGPSDictionary }
    private var xmpKey: CFString { "{XMP}" as CFString }
    private var qtKey: CFString { "{QuickTime}" as CFString }

    private var exifDateKey: CFString { kCGImagePropertyExifDateTimeOriginal }
    private var tiffDateKey: CFString { kCGImagePropertyTIFFDateTime }

    private var iptcDescrKey: CFString { kCGImagePropertyIPTCCaptionAbstract }
    private var tiffDescrKey: CFString { kCGImagePropertyTIFFImageDescription }

    private var iptcTitleKey: CFString { kCGImagePropertyIPTCObjectName }
    private var xmpTitleKey: CFString { "dc:title" as CFString }
    private var qtTitleKey: CFString { "Title" as CFString }

    private var gpsLatKey: CFString { kCGImagePropertyGPSLatitude }
    private var gpsLatRefKey: CFString { kCGImagePropertyGPSLatitudeRef }
    private var gpsLonKey: CFString { kCGImagePropertyGPSLongitude }
    private var gpsLonRefKey: CFString { kCGImagePropertyGPSLongitudeRef }

    private let props: [CFString: Any]

    init(_ props: [CFString: Any]) { self.props = props }

    var exif: [CFString: Any]? { props[exifKey] as? [CFString: Any] }
    var tiff: [CFString: Any]? { props[tiffKey] as? [CFString: Any] }
    var iptc: [CFString: Any]? { props[iptcKey] as? [CFString: Any] }
    var gps: [CFString: Any]? { props[gpsKey] as? [CFString: Any] }
    var xmp: [CFString: Any]? { props[xmpKey] as? [CFString: Any] }
    var qt: [CFString: Any]? { props[qtKey] as? [CFString: Any] }

    var dateTaken: Date? {
        guard let dateString = dateTakenString else { return nil }
        guard let date = Formatter.date(from: dateString) else { return nil }

        return date
    }

    var description: String? {
        guard let description = descriptionString else { return nil }
        return description
    }

    var title: String? {
        guard let title = titleString else { return nil }
        return title
    }
    
    var location: GeoCoordinate? {
        guard let gpsLat = parseDouble(gps?[gpsLatKey]) else { return nil }
        guard let gpsLatRef = gps?[gpsLatRefKey] as? String else { return nil }
        guard let gpsLon = parseDouble(gps?[gpsLonKey]) else { return nil }
        guard let gpsLonRef = gps?[gpsLonRefKey] as? String else { return nil }

        let latitude = (gpsLatRef.uppercased() == "S") ? -abs(gpsLat) : abs(gpsLat)
        let longitude = (gpsLonRef.uppercased() == "W") ? -abs(gpsLon) : abs(gpsLon)
        
        return GeoCoordinate(latitude, longitude)
    }

    private var titleString: String? {
        let iptcTitle = iptc?[iptcTitleKey] as? String
        let xmpTitle = xmp?[xmpTitleKey] as? String
        let qtTitle = qt?[qtTitleKey] as? String

        return iptcTitle ?? xmpTitle ?? qtTitle
    }

    private var descriptionString: String? {
        let iptcDescr = iptc?[iptcDescrKey] as? String
        let tiffDescr = tiff?[tiffDescrKey] as? String

        return iptcDescr ?? tiffDescr
    }

    private var dateTakenString: String? {
        let exifDate = exif?[exifDateKey] as? String
        let tiffDate = tiff?[tiffDateKey] as? String

        return exifDate ?? tiffDate
    }

    private let Formatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        return formatter
    }()

    private func parseDouble(_ value: Any?) -> Double? {
        if let d = value as? Double { return d }
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String { return Double(s) }

        return nil
    }

}
