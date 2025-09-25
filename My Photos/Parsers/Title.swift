import Foundation
import ImageIO

struct Title {
    static func parse(from props: [CFString: Any]) -> String? {
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
            if let dcTitle = xmp["dc:title" as CFString] as? String,
                !dcTitle.isEmpty
            {
                return dcTitle
            }

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
