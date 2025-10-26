import Foundation
import ImageIO

struct ACDSeeCategories {
    private let namespace = "http://ns.acdsee.com/iptc/1.0/"
    private let tags: [CGImageMetadataTag]

    init(_ tags: [CGImageMetadataTag]) { self.tags = tags }

    var xml: String? {
        let xml = tags.first(where: { tag in
            let ns = CGImageMetadataTagCopyNamespace(tag) as String?
            let name = CGImageMetadataTagCopyName(tag) as String?

            return ns == namespace && name == "categories"
        })
        .flatMap(tagToString)

        guard let xml else { return nil }
        return xml
    }

    #if os(macOS)
        var categoriesXml: XMLDocument? {
            guard let xml else { return nil }
            guard let doc = try? XMLDocument(xmlString: xml) else { return nil }

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
