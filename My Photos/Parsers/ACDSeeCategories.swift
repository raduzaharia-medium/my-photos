import Foundation
import ImageIO

let namespace = "http://ns.acdsee.com/iptc/1.0/"

struct ACDSeeCategories {
    static func parse(from tags: [CGImageMetadataTag]) -> [String] {
        guard
            let xml = tags.first(where: {
                (CGImageMetadataTagCopyNamespace($0) as String?) == namespace
                    && (CGImageMetadataTagCopyName($0) as String?)
                        == "categories"
            }).flatMap(tagToString)
        else { return [] }

        return parseACDSeeCategoriesXML(xml)
    }

    private static func tagToString(_ tag: CGImageMetadataTag) -> String? {
        guard let any = CGImageMetadataTagCopyValue(tag) else { return nil }

        if let s = any as? String { return s }
        if let d = any as? Data, let s = String(data: d, encoding: .utf8) {
            return s
        }

        return String(describing: any)
    }

    private static func parseACDSeeCategoriesXML(_ xmlString: String)
        -> [String]
    {
        guard let data = xmlString.data(using: .utf8) else { return [] }
        let delegate = ACDSeeCategoriesDelegate()
        let parser = XMLParser(data: data)

        parser.delegate = delegate

        if parser.parse() {
            var seen = Set<String>()
            return delegate.paths.filter { seen.insert($0).inserted }
        } else {
            return []
        }
    }
}
