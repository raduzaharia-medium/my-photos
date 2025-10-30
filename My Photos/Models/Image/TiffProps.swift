import Foundation
import ImageIO

struct TiffProps {
    private var tiffKey: CFString { kCGImagePropertyTIFFDictionary }

    private var tiffDateKey: CFString { kCGImagePropertyTIFFDateTime }
    private var tiffDescrKey: CFString { kCGImagePropertyTIFFImageDescription }

    private let props: [CFString: Any]

    init(_ props: [CFString: Any]) {
        self.props = props
    }

    var tiff: [CFString: Any]? { props[tiffKey] as? [CFString: Any] }

    var dateTaken: Date? {
        let tiffDate = tiff?[tiffDateKey] as? String
        guard let dateString = tiffDate else { return nil }
        guard let date = Formatter.date(from: dateString) else { return nil }

        return date
    }
    var description: String? { tiff?[tiffDescrKey] as? String }

    private let Formatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        return formatter
    }()
}
