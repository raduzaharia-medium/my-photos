import Foundation
import ImageIO

struct XmpProps {
    private var xmpTitleKey: CFString { "dc:title" as CFString }
    private var xmpDescriptionKey: CFString { "dc:description" as CFString }
    private var xmpAlbumKey: CFString { "xmpDM:album" as CFString }
    private var xmpLocationCreated: CFString {
        "Iptc4xmpExt:LocationCreated" as CFString
    }
    private var xmpCityKey: CFString { "Iptc4xmpExt:City" as CFString }
    private var xmpCountryKey: CFString {
        "Iptc4xmpExt:CountryName" as CFString
    }
    private var xmpDefaultKey: CFString { "dc[x-default]" as CFString }

    private let meta: CGImageMetadata?

    init(_ meta: CGImageMetadata?) {
        self.meta = meta
    }

    var xmp: CGImageMetadata? { meta }

    var title: String? {
        guard let tag = defaultTitleTag else { return nil }
        guard let result = CGImageMetadataTagCopyValue(tag) else { return nil }

        return result as? String
    }
    var description: String? {
        guard let tag = defaultDescriptionTag else { return nil }
        guard let result = CGImageMetadataTagCopyValue(tag) else { return nil }

        return result as? String
    }
    var album: String? {
        guard let tag = albumTag else { return nil }
        guard let result = CGImageMetadataTagCopyValue(tag) else { return nil }

        return result as? String
    }
    var country: String? {
        guard let tag = countryTag else { return nil }
        guard let result = CGImageMetadataTagCopyValue(tag) else { return nil }

        return result as? String
    }
    var city: String? {
        guard let tag = cityTag else { return nil }
        guard let result = CGImageMetadataTagCopyValue(tag) else { return nil }

        return result as? String
    }

    private var titleTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        return CGImageMetadataCopyTagWithPath(meta, nil, xmpTitleKey)
    }
    private var defaultTitleTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        guard let parent = titleTag else { return nil }

        return CGImageMetadataCopyTagWithPath(meta, parent, xmpDefaultKey)
    }

    private var descriptionTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        return CGImageMetadataCopyTagWithPath(meta, nil, xmpDescriptionKey)
    }
    private var defaultDescriptionTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        guard let parent = descriptionTag else { return nil }

        return CGImageMetadataCopyTagWithPath(meta, parent, xmpDefaultKey)
    }

    private var albumTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        return CGImageMetadataCopyTagWithPath(meta, nil, xmpAlbumKey)
    }

    private var locationCreatedTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        return CGImageMetadataCopyTagWithPath(meta, nil, xmpLocationCreated)
    }
    private var locationCreatedArray: [CGImageMetadataTag]? {
        guard let tag = locationCreatedTag else { return nil }
        return CGImageMetadataTagCopyValue(tag) as? [CGImageMetadataTag]
    }
    private var firstLocationCreated: CGImageMetadataTag? {
        locationCreatedArray?.first
    }
    private var cityTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        guard let parent = firstLocationCreated else { return nil }

        return CGImageMetadataCopyTagWithPath(meta, parent, xmpCityKey)
    }
    private var countryTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        guard let parent = firstLocationCreated else { return nil }

        return CGImageMetadataCopyTagWithPath(meta, parent, xmpCountryKey)
    }
}
