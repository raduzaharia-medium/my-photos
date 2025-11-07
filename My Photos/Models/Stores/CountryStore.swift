import SwiftData
import SwiftUI

@ModelActor
actor CountryStore {
    @discardableResult
    func create(_ name: String) throws -> UUID {
        let item = PlaceCountry(name)

        modelContext.insert(item)
        try modelContext.save()
        return item.id
    }

    func update(_ id: UUID, name: String) throws {
        let item = try get(id)
        guard let item else { throw DataStoreError.invalidPredicate }

        item.country = name
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

    private func get(_ id: UUID) throws -> PlaceCountry? {
        let predicate = #Predicate<PlaceCountry> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
}
