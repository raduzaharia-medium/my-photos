import SwiftData
import SwiftUI

@ModelActor
actor MonthStore {
    @discardableResult
    func create(_ parent: DateTakenYear, _ month: Int) throws -> UUID {
        let item = DateTakenMonth(parent, month)

        modelContext.insert(item)
        try modelContext.save()
        return item.id
    }

    func update(_ id: UUID, _ month: Int) throws {
        let item = try get(id)
        guard let item else { throw DataStoreError.invalidPredicate }

        item.month = month
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

    private func get(_ id: UUID) throws -> DateTakenMonth? {
        let predicate = #Predicate<DateTakenMonth> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
}
