import Foundation
import ImageIO

struct ACDSeeCategories {
    private let namespace = "http://ns.acdsee.com/iptc/1.0/"
    private var acdSeeCategoriesKey: CFString {
        "acdsee:categories" as CFString
    }

    private let meta: CGImageMetadata?

    init(_ meta: CGImageMetadata?) { self.meta = meta }

    var categories: String? {
        guard let tag = categoriesTag else { return nil }
        guard let result = CGImageMetadataTagCopyValue(tag) else { return nil }

        return result as? String
    }

    #if os(macOS)
        var categoriesXml: XMLDocument? {
            guard let categories else { return nil }
            guard let doc = try? XMLDocument(xmlString: categories) else {
                return nil
            }
            
            return doc
        }
    #endif

    #if os(macOS)
        var placesXml: XMLDocument? {
            guard let categoriesXml else { return nil }

            let xpath = "//Category[normalize-space(text())='Places']"
            let nodes =
                try? categoriesXml.nodes(forXPath: xpath) as? [XMLElement]
            guard let nodes else { return nil }

            guard let node = nodes.first else { return nil }

            node.detach()

            return XMLDocument(rootElement: node)
        }
    #endif

    var places: [ParsedTag] {
        #if os(macOS)
            guard let placesXml else { return [] }
            return placesXml.buildTags()
        #else
            return []
        #endif
    }

    var country: String? {
        return places.first?.name
    }
    var locality: String? {
        return places.first?.children.first?.name
    }

    private var categoriesTag: CGImageMetadataTag? {
        guard let meta else { return nil }
        return CGImageMetadataCopyTagWithPath(meta, nil, acdSeeCategoriesKey)
    }

    private func tagToString(_ tag: CGImageMetadataTag) -> String? {
        guard let any = CGImageMetadataTagCopyValue(tag) else { return nil }

        if let s = any as? String { return s }
        if let d = any as? Data, let s = String(data: d, encoding: .utf8) {
            return s
        }

        return String(describing: any)
    }
}

#if os(macOS)
    extension XMLDocument {
        func buildTags() -> [ParsedTag] {
            guard let root = rootElement() else { return [] }

            func build(from node: XMLElement) -> ParsedTag? {
                guard let name = node.categoryLabel() else { return nil }
                var tag = ParsedTag(name: name)
                for case let child as XMLElement in node.children ?? [] {
                    if let builtChild = build(from: child) {
                        tag.addChild(builtChild)
                    }
                }
                return tag
            }

            var tops: [ParsedTag] = []
            for case let child as XMLElement in root.children ?? [] {
                if let top = build(from: child) {
                    tops.append(top)
                }
            }
            return tops
        }
    }
#endif

#if os(macOS)
    extension XMLElement {
        func categoryLabel() -> String? {
            let text = (children ?? [])
                .filter { $0.kind == .text }
                .compactMap { $0.stringValue }
                .joined()
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? nil : text
        }
    }
#endif
