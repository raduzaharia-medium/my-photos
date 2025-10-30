import Foundation
import ImageIO

struct ExifProps {
    private var exifKey: CFString { kCGImagePropertyExifDictionary }
    private var exifDateKey: CFString { kCGImagePropertyExifDateTimeOriginal }

    private let props: [CFString: Any]

    init(_ props: [CFString: Any]) { self.props = props }

    var exif: [CFString: Any]? { props[exifKey] as? [CFString: Any] }

    var dateTaken: Date? {
        guard let exifDate = exif?[exifDateKey] as? String else { return nil }
        guard let date = Formatter.date(from: exifDate) else { return nil }

        return date
    }

    private let Formatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        return formatter
    }()
}
