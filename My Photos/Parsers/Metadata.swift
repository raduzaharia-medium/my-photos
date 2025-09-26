import Foundation
import ImageIO

#if canImport(MobileCoreServices)
    import MobileCoreServices
#endif

enum XMPError: Error { case noImageSource, noMetadata }

struct Metadata {
    static func props(in url: URL) -> [CFString: Any] {
        let src = CGImageSourceCreateWithURL(url as CFURL, nil)
        guard let src else { return [:] }

        let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil)
        let result = props as? [CFString: Any]
        guard let result else { return [:] }

        return result
    }

    static func metadata(in url: URL) -> CGImageMetadata? {
        let src = CGImageSourceCreateWithURL(url as CFURL, nil)
        guard let src else { return nil }

        let metadata = CGImageSourceCopyMetadataAtIndex(src, 0, nil)
        guard let metadata else { return nil }
       
        return metadata
    }

    static func tags(in url: URL) -> [CGImageMetadataTag] {
        guard let metadata = metadata(in: url) else { return [] }

        let tags = CGImageMetadataCopyTags(metadata) as? [CGImageMetadataTag]
        guard let tags else { return [] }
       
        return tags
    }
}
