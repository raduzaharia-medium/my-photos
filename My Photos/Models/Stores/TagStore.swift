import SwiftData
import SwiftUI

enum StoreError: Error {
    case notFound
    case saveFailed(underlying: Error)
}

final class TagStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getTags() -> [Tag] {
        let descriptor = FetchDescriptor<Tag>(
            sortBy: [
                SortDescriptor(\Tag.name, order: .forward)
            ]
        )

        if let fetched = try? context.fetch(descriptor) { return fetched }
        return []
    }

    func getTag(named name: String) -> Tag? {
        let tags = getTags().filter { $0.name == name }
        return tags.first
    }

    @discardableResult
    func create(name: String) throws -> Tag {
        let tag = Tag(name: name)

        context.insert(tag)
        try context.save()

        return tag
    }

    func insert(_ tag: Tag) throws {
        context.insert(tag)
        try context.save()
    }

    func insert(_ tags: [Tag]) throws {
        for tag in tags {
            context.insert(tag)
        }

        try context.save()
    }

    func insertIfMissing(_ tag: Tag) throws {
        let tags = getTags().filter { $0.name == tag.name }
        if !tags.isEmpty { return }

        context.insert(tag)
    }

    @discardableResult
    func ensure(_ incoming: ParsedTag) -> Tag {
        if let existing = getTag(named: incoming.name) {
            for child in incoming.children {
                let ensuredChild = ensure(child)

                if !existing.children.contains(where: { $0 === ensuredChild }) {
                    existing.children.append(ensuredChild)
                }
            }

            return existing
        } else {
            let newNode = Tag(name: incoming.name)

            for child in incoming.children {
                let ensuredChild = ensure(child)

                if !newNode.children.contains(where: { $0 === ensuredChild }) {
                    newNode.children.append(ensuredChild)
                }
            }

            context.insert(newNode)
            return newNode
        }
    }

    func ensure(_ incoming: [ParsedTag]) -> [Tag] {
        let resolved: [Tag] = incoming.map { t in ensure(t) }
        return resolved
    }

    func createIfMissing(name: String) throws -> Tag {
        let tags = getTags().filter { $0.name == name }
        if !tags.isEmpty {
            return tags.first!
        }

        let tag = Tag(name: name)

        context.insert(tag)
        try context.save()

        return tag
    }

    @discardableResult
    func update(_ tag: Tag, name: String, parent: Tag? = nil) throws -> Tag {
        guard let tag = context.model(for: tag.id) as? Tag else {
            throw StoreError.notFound
        }

        tag.name = name
        tag.parent = parent

        var stack = tag.children
        while let node = stack.popLast() {
            stack.append(contentsOf: node.children)
        }

        try context.save()
        return tag
    }

    func upsert(_ tag: Tag?, name: String) throws -> Tag {
        if let tag {
            try update(tag, name: name)
        } else {
            try create(name: name)
        }
    }

    func delete(_ tag: Tag) throws {
        guard let tag = context.model(for: tag.id) as? Tag else {
            throw StoreError.notFound
        }

        context.delete(tag)
        try context.save()
    }

    func delete(_ tags: [Tag]) throws {
        guard !tags.isEmpty else { return }

        for tag in tags {
            guard let tag = context.model(for: tag.id) as? Tag else {
                throw StoreError.notFound
            }

            context.delete(tag)
        }

        try context.save()
    }
}
