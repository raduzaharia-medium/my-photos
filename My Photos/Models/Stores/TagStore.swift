import SwiftData
import SwiftUI

final class TagStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func get() -> [Tag] {
        let sort = SortDescriptor(\Tag.key)
        let descriptor = FetchDescriptor<Tag>(sortBy: [sort])

        guard let results = try? context.fetch(descriptor) else { return [] }
        return results
    }
    func get(_ name: String) -> Tag? {
        let predicate = #Predicate<Tag> { $0.name == name }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    func get(_ id: UUID) -> Tag? {
        let predicate = #Predicate<Tag> { $0.id == id }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }

    func findOrCreate(_ name: String, _ parent: Tag? = nil) throws -> Tag {
        if let existing = get(name) { return existing }
        return try create(name, parent)
    }

    @discardableResult
    func create(_ name: String, _ parent: Tag? = nil) throws -> Tag {
        let newItem = Tag(name: name, parent: parent)

        try insert(newItem)
        return newItem
    }

    func insert(_ item: Tag) throws {
        context.insert(item)
        try context.save()
    }
    func insert(_ items: [Tag]) throws {
        for item in items {
            context.insert(item)
        }

        try context.save()
    }

    @discardableResult
    func update(_ item: Tag, _ name: String, _ parent: Tag? = nil) throws -> Tag
    {
        item.name = name
        item.parent = parent
        item.key = Tag.key(parent, name)

        try context.save()
        return item
    }
    @discardableResult
    func update(_ id: UUID, _ name: String?, _ parent: Tag? = nil) throws -> Tag? {
        guard let tag = get(id) else { return nil }
        return try update(tag, name ?? tag.name, parent)
    }

    func delete(_ item: Tag) throws {
        context.delete(item)
        try context.save()
    }
    func delete(_ items: [Tag]) throws {
        guard !items.isEmpty else { return }

        for item in items { context.delete(item) }
        try context.save()
    }

    @discardableResult
    func ensure(_ incoming: ParsedTag) -> Tag {
        if let existing = get(incoming.name) {
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
}
