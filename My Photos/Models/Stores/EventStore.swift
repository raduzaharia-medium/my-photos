import SwiftData
import SwiftUI

@ModelActor
actor EventStore {
    @discardableResult
    func create(_ name: String) throws -> UUID {
        let item = Event(name)

        modelContext.insert(item)
        try modelContext.save()
        return item.id
    }

    func update(_ id: UUID, _ name: String) throws {
        let item = try get(id)
        guard let item else { throw DataStoreError.invalidPredicate }

        item.name = name
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

    private func get(_ id: UUID) throws -> Event? {
        let predicate = #Predicate<Event> { album in album.id == id }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
}
