import Foundation
import ImageIO

struct Metadata {
    static func props(in url: URL) -> [CFString: Any] {
        guard
            let src = CGImageSourceCreateWithURL(url as CFURL, nil),
            let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil)
                as? [CFString: Any]
        else {
            return [:]
        }

        return props
    }

    static func tags(in url: URL) -> [CGImageMetadataTag] {
        guard
            let src = CGImageSourceCreateWithURL(url as CFURL, nil),
            let metadata = CGImageSourceCopyMetadataAtIndex(src, 0, nil),
            let tags = CGImageMetadataCopyTags(metadata)
                as? [CGImageMetadataTag]
        else {
            return []
        }

        return tags
    }
}
