import SwiftData
import SwiftUI

@ModelActor
actor DayStore {
    @discardableResult
    func create(_ parent: DateTakenMonth, _ day: Int) throws -> UUID {
        let item = DateTakenDay(parent, day)

        modelContext.insert(item)
        try modelContext.save()
        return item.id
    }

    func update(_ id: UUID, _ day: Int) throws {
        let item = try get(id)
        guard let item else { throw DataStoreError.invalidPredicate }

        item.value = day
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

    private func get(_ id: UUID) throws -> DateTakenDay? {
        let predicate = #Predicate<DateTakenDay> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenDay>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
}
