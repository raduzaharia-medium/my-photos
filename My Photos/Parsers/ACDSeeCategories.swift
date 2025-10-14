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
    var categoriesXml: XMLDocument? {
        guard let xml else { return nil }
        guard let doc = try? XMLDocument(xmlString: xml) else { return nil }

        return doc
    }
    var placesXml: XMLDocument? {
        guard let categoriesXml else { return nil }

        let xpath = "//Category[normalize-space(text())='Places']"
        let nodes = try? categoriesXml.nodes(forXPath: xpath) as? [XMLElement]
        guard let nodes else { return nil }

        guard let node = nodes.first else { return nil }

        node.detach()

        return XMLDocument(rootElement: node)
    }

    var places: [ParsedTag] {
        guard let placesXml else { return [] }
        return placesXml.buildTags()
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

extension XMLDocument {
    func buildTags() -> [ParsedTag] {
        guard let root = rootElement() else { return [] }
        var tops: [ParsedTag] = []

        func visit(_ node: XMLElement, parent: ParsedTag?) {
            guard let name = node.categoryLabel() else { return }

            let tag = ParsedTag(name: name)
            if parent == nil { tops.append(tag) }

            for case let child as XMLElement in node.children ?? [] {
                visit(child, parent: tag)
            }
        }

        for case let child as XMLElement in root.children ?? [] {
            visit(child, parent: nil)
        }
        return tops
    }
}

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
