import SwiftData
import SwiftUI

@ModelActor
actor TagStore {
    @discardableResult
    func create(_ name: String, _ parentId: UUID? = nil) throws -> UUID {
        var parent: Tag? = nil

        if let parentId { parent = try get(parentId) }
        let item = Tag(name: name, parent: parent)

        modelContext.insert(item)
        try modelContext.save()
        return item.id
    }

    func update(_ id: UUID, _ name: String?, _ parentId: UUID? = nil) throws {
        let item = try get(id)
        guard let item else { throw DataStoreError.invalidPredicate }

        var parent: Tag? = nil
        if let parentId { parent = try get(parentId) }

        if let name { item.name = name }
        item.parent = parent
        item.key = Tag.key(parent, item.name)

        try modelContext.save()
    }

    func delete(_ id: UUID) throws {
        let item = try get(id)
        guard let item else { return }

        modelContext.delete(item)
        try modelContext.save()
    }
    func delete(_ ids: [UUID]) throws {
        guard !ids.isEmpty else { return }

        for item in ids {
            let item = try get(item)
            guard let item else { continue }

            modelContext.delete(item)
        }

        try modelContext.save()
    }

    private func get(_ id: UUID?) throws -> Tag? {
        guard let id else { return nil }

        let predicate = #Predicate<Tag> { $0.id == id }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }

}
