import SwiftData
import SwiftUI

enum TagStoreError: Error {
    case tagNotFound
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

    func getTag(named name: String, kind: TagKind) -> Tag? {
        let tags = getTags().filter { $0.name == name && $0.kind == kind }
        return tags.first
    }

    @discardableResult
    func create(name: String, kind: TagKind) throws -> Tag {
        let tag = Tag(name: name, kind: kind)

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
        let tags = getTags().filter {
            $0.name == tag.name && $0.kind == tag.kind
        }
        if !tags.isEmpty { return }

        context.insert(tag)
    }

    @discardableResult
    func ensureTagAndChildren(_ incoming: Tag, parent: Tag? = nil) -> Tag {
        if let existing = getTag(named: incoming.name, kind: incoming.kind) {
            for child in incoming.children {
                let ensuredChild = ensureTagAndChildren(child, parent: existing)

                if !existing.children.contains(where: { $0 === ensuredChild }) {
                    existing.children.append(ensuredChild)
                }
            }

            return existing
        } else {
            let newNode = Tag(
                name: incoming.name,
                kind: incoming.kind,
                parent: parent
            )

            for child in incoming.children {
                let ensuredChild = ensureTagAndChildren(child, parent: newNode)

                if !newNode.children.contains(where: { $0 === ensuredChild }) {
                    newNode.children.append(ensuredChild)
                }
            }

            context.insert(newNode)
            return newNode
        }
    }

    func createIfMissing(name: String, kind: TagKind) throws -> Tag {
        let tags = getTags().filter { $0.name == name && $0.kind == kind }
        if !tags.isEmpty {
            return tags.first!
        }

        let tag = Tag(name: name, kind: kind)

        context.insert(tag)
        try context.save()

        return tag
    }

    @discardableResult
    func update(_ id: PersistentIdentifier, name: String, kind: TagKind, parent: Tag? = nil) throws
        -> Tag
    {
        guard let tag = context.model(for: id) as? Tag else {
            throw TagStoreError.tagNotFound
        }

        tag.name = name
        tag.kind = kind
        tag.parent = parent

        try context.save()
        return tag
    }

    func upsert(_ id: PersistentIdentifier?, name: String, kind: TagKind) throws
        -> Tag
    {
        if let id {
            try update(id, name: name, kind: kind)
        } else {
            try create(name: name, kind: kind)
        }
    }

    func delete(_ id: PersistentIdentifier) throws {
        guard let tag = context.model(for: id) as? Tag else {
            throw TagStoreError.tagNotFound
        }

        context.delete(tag)
        try context.save()
    }

    func delete(_ ids: [PersistentIdentifier]) throws {
        guard !ids.isEmpty else { return }

        for id in ids {
            guard let tag = context.model(for: id) as? Tag else {
                throw TagStoreError.tagNotFound
            }

            context.delete(tag)
        }

        try context.save()
    }
}
