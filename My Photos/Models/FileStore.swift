import Foundation
import ImageIO
import MapKit
import UniformTypeIdentifiers

struct FileStore {
    func parseImageFiles(in url: URL) async throws -> [Photo] {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
        }

        let imageFiles = try getImageFiles(in: url)
        var result: [Photo] = []

        for imageFile in imageFiles {
            let props = try readEXIF(in: imageFile)
            if props.isEmpty { continue }

            let title = getTitle(from: props) ?? imageFile.lastPathComponent
            let dateTaken = getDateTaken(from: props)
            let location = getLocation(from: props)

            if let location {
                if let request = MKReverseGeocodingRequest(
                    location: CLLocation(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                ) {
                    let items = try await request.mapItems
                    if let item = items.first {
                        let placemark = item.addressRepresentations?.description
                        print("Resolved place: \(placemark)")
                    } else {
                        print("No reverse geocoding results.")
                    }
                    print(request.description)
                }
            }

            result.append(
                Photo(
                    title: title,
                    dateTaken: dateTaken,
                    location: location
                )
            )
        }

        return result
    }

    private func getImageFiles(in url: URL) throws -> [URL] {
        guard
            let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: [
                    .isRegularFileKey, .contentTypeKey,
                ]
            )
        else { return [] }

        let result = enumerator.compactMap { $0 as? URL }
            .filter { url in
                guard
                    let values = try? url.resourceValues(forKeys: [
                        .isRegularFileKey, .contentTypeKey,
                    ])
                else {
                    return false
                }

                return values.isRegularFile == true
                    && values.contentType?.conforms(to: .image) == true
            }

        return result
    }

    private func readEXIF(in url: URL) throws -> [CFString: Any] {
        guard
            let src = CGImageSourceCreateWithURL(url as CFURL, nil),
            let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil)
                as? [CFString: Any]
        else {
            return [:]
        }

        return props
    }

    private static let EXIFDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        return formatter
    }()

    private func getDateTaken(from props: [CFString: Any]) -> Date? {
        let exif = props["{Exif}" as CFString] as? [CFString: Any]
        let tiff = props["{TIFF}" as CFString] as? [CFString: Any]

        let dateString =
            (exif?[kCGImagePropertyExifDateTimeOriginal] as? String)
            ?? (tiff?[kCGImagePropertyTIFFDateTime] as? String)

        return dateString.flatMap { FileStore.EXIFDateFormatter.date(from: $0) }
    }

    private func getLocation(from props: [CFString: Any])
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

    private func getTitle(from props: [CFString: Any]) -> String? {
        if let iptc = props["{IPTC}" as CFString] as? [CFString: Any] {
            if let objectName = iptc[kCGImagePropertyIPTCObjectName] as? String,
                !objectName.isEmpty
            {
                return objectName
            }
            if let headline = iptc[kCGImagePropertyIPTCHeadline] as? String,
                !headline.isEmpty
            {
                return headline
            }
            if let caption = iptc[kCGImagePropertyIPTCCaptionAbstract]
                as? String, !caption.isEmpty
            {
                return caption
            }
        }

        if let tiff = props["{TIFF}" as CFString] as? [CFString: Any],
            let desc = tiff[kCGImagePropertyTIFFImageDescription] as? String,
            !desc.isEmpty
        {
            return desc
        }

        if let xmp = props["{XMP}" as CFString] as? [CFString: Any] {
            // Some encoders expose dc:title as a simple string
            if let dcTitle = xmp["dc:title" as CFString] as? String,
                !dcTitle.isEmpty
            {
                return dcTitle
            }
            // Others use an alt-text container (dictionary of language codes)
            if let alt = xmp["dc:title" as CFString] as? [String: Any] {
                if let def = alt["x-default"] as? String, !def.isEmpty {
                    return def
                }
                if let any = alt.values.compactMap({ $0 as? String }).first(
                    where: { !$0.isEmpty })
                {
                    return any
                }
            }
        }

        if let qt = props["{QuickTime}" as CFString] as? [CFString: Any],
            let qtTitle = qt["Title" as CFString] as? String,
            !qtTitle.isEmpty
        {
            return qtTitle
        }

        return nil
    }
}
