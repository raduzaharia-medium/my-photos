import SwiftData
import SwiftUI

@ModelActor
actor TagStore {
    func get() -> [Tag] {
        let sort = SortDescriptor(\Tag.key)
        let descriptor = FetchDescriptor<Tag>(sortBy: [sort])
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return [] }
        return results
    }
    func get(_ name: String) -> Tag? {
        let predicate = #Predicate<Tag> { $0.name == name }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    func get(_ id: UUID) -> Tag? {
        let predicate = #Predicate<Tag> { $0.id == id }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }

    @discardableResult
    func create(_ name: String, _ parentId: UUID? = nil) throws -> UUID {
        let newItem = try createInternal(name, parentId)
        return newItem.id
    }

    func insert(_ item: Tag) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    func insert(_ items: [Tag]) throws {
        for item in items { modelContext.insert(item) }
        try modelContext.save()
    }

    func update(_ id: UUID, _ name: String?, _ parentId: UUID? = nil) throws {
        let item = get(id)
        guard let item else { throw DataStoreError.invalidPredicate }

        var parent: Tag? = nil
        if let parentId { parent = get(parentId) }

        if let name { item.name = name }
        item.parent = parent
        item.key = Tag.key(parent, item.name)

        try modelContext.save()
    }

    func delete(_ id: UUID) throws {
        let item = get(id)
        guard let item else { return }

        modelContext.delete(item)
        try modelContext.save()
    }
    func delete(_ ids: [UUID]) throws {
        guard !ids.isEmpty else { return }

        for item in ids {
            let item = get(item)
            guard let item else { continue }

            modelContext.delete(item)
        }
        
        try modelContext.save()
    }

    func ensure(_ incoming: ParsedTag) -> [UUID] {
        let resolved = ensureInternal(incoming)
        let flattened = resolved.flatten()
        let ids = flattened.map(\.id)

        return ids
    }

    func ensure(_ incoming: [ParsedTag]) -> [UUID] {
        let resolved = incoming.map { t in ensure(t) }
        return resolved.flatMap(\.self)
    }

    private func ensureInternal(_ incoming: ParsedTag) -> Tag {
        if let existing = get(incoming.name) {
            for child in incoming.children {
                let ensuredChild = ensureInternal(child)

                if !existing.children.contains(where: { $0 === ensuredChild }) {
                    existing.children.append(ensuredChild)
                }
            }

            return existing
        } else {
            let newNode = Tag(name: incoming.name)

            for child in incoming.children {
                let ensuredChild = ensureInternal(child)

                if !newNode.children.contains(where: { $0 === ensuredChild }) {
                    newNode.children.append(ensuredChild)
                }
            }

            modelContext.insert(newNode)
            return newNode
        }
    }

    private func findOrCreate(_ name: String, _ parent: Tag? = nil) throws
        -> Tag
    {
        if let existing = get(name) { return existing }
        return try createInternal(name, parent?.id)
    }

    private func createInternal(_ name: String, _ parentId: UUID? = nil) throws
        -> Tag
    {
        if let parentId {
            let parent = get(parentId)
            let newItem = Tag(name: name, parent: parent)

            try insert(newItem)
            return newItem
        }
        
        let newItem = Tag(name: name)

        try insert(newItem)
        return newItem
    }

}
