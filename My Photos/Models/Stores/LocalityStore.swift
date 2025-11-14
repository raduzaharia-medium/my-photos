import SwiftData
import SwiftUI

@ModelActor
actor LocalityStore {
    @discardableResult
    func create(_ parent: PlaceCountry, _ name: String) throws -> UUID {
        let item = PlaceLocality(parent, name)

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

    private func get(_ id: UUID) throws -> PlaceLocality? {
        let predicate = #Predicate<PlaceLocality> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceLocality>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
}
