import Foundation
import ImageIO

private struct Node {
    var name: String
    let assigned: Bool
    var textBuffer: String
}

final class ACDSeeCategoriesDelegate: NSObject, XMLParserDelegate {
    private var stack: [Node] = []
    private(set) var paths: [String] = []

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        guard elementName == "Category" else { return }
        let assigned = attributeDict["Assigned"] == "1"

        stack.append(Node(name: "", assigned: assigned, textBuffer: ""))
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !stack.isEmpty else { return }

        stack[stack.count - 1].textBuffer += string

        let trimmed = stack[stack.count - 1].textBuffer.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        stack[stack.count - 1].name = trimmed
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard elementName == "Category", var node = stack.popLast() else {
            return
        }

        node.name = node.name.trimmingCharacters(in: .whitespacesAndNewlines)

        let fullPath = (stack.map { $0.name } + [node.name])
            .filter { !$0.isEmpty }
            .joined(separator: "|")

        if node.assigned && !fullPath.isEmpty {
            paths.append(fullPath)
        }
    }
}
