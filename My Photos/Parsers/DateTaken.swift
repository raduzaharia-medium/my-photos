import Foundation
import ImageIO

struct DateTaken {
    static func parse(from props: [CFString: Any]) -> Date? {
        let exif = props["{Exif}" as CFString] as? [CFString: Any]
        let tiff = props["{TIFF}" as CFString] as? [CFString: Any]
        
        let dateString =
        (exif?[kCGImagePropertyExifDateTimeOriginal] as? String)
        ?? (tiff?[kCGImagePropertyTIFFDateTime] as? String)
        
        return dateString.flatMap { EXIFDateFormatter.date(from: $0) }
    }
    
    private static let EXIFDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter
    }()
}
