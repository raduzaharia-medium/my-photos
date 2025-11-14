import SwiftData
import SwiftUI

@ModelActor
actor YearStore {
    func create(_ year: Int) throws -> UUID {
        let item = DateTakenYear(year)

        modelContext.insert(item)
        try modelContext.save()
        return item.id
    }

    func update(_ id: UUID, year: Int) throws {
        let item = try get(id)
        guard let item else { throw DataStoreError.invalidPredicate }

        item.value = year
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

    private func get(_ id: UUID?) throws -> DateTakenYear? {
        guard let id else { return nil }

        let predicate = #Predicate<DateTakenYear> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
}
