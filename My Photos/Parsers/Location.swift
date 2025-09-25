import Foundation
import ImageIO

struct Location {
    static func parse(from props: [CFString: Any], or categories: [String])
        -> Place
    {
        var place = Place()

        place.city = place.city ?? iptc(kCGImagePropertyIPTCCity, props)
        place.country =
            place.country
            ?? iptc(kCGImagePropertyIPTCCountryPrimaryLocationName, props)

        place.city = place.city ?? xmp("photoshop:City", props)
        place.country = place.country ?? xmp("photoshop:Country", props)

        let threeParts = categories.first { partsIfPlaces($0)?.count == 3 }
            .flatMap(partsIfPlaces)
        let twoParts = categories.first { partsIfPlaces($0)?.count == 2 }
            .flatMap(partsIfPlaces)

        if let parts = threeParts ?? twoParts {
            if parts.count == 3 {
                if place.country == nil { place.country = clean(parts[1]) }
                if place.city == nil { place.city = clean(parts[2]) }
            } else {
                if place.country == nil { place.country = clean(parts[1]) }
            }
        }

        return place
    }

    private static func clean(_ s: String?) -> String? {
        guard let s = s?.trimmingCharacters(in: .whitespacesAndNewlines),
            !s.isEmpty
        else { return nil }
        return s
    }

    private static func iptc(_ key: CFString, _ props: [CFString: Any])
        -> String?
    {
        guard
            let iptc = props[kCGImagePropertyIPTCDictionary] as? [CFString: Any]
        else { return nil }
        return clean(iptc[key] as? String)
    }

    private static func xmp(_ key: String, _ props: [CFString: Any]) -> String?
    {
        guard
            let xmp = props["{XMP}" as CFString] as? [String: Any]
        else { return nil }
        return clean(xmp[key] as? String)
    }

    private static func partsIfPlaces(_ s: String) -> [String]? {
        guard s.lowercased().hasPrefix("places|") else { return nil }
        return s.split(separator: "|").map {
            String($0).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
