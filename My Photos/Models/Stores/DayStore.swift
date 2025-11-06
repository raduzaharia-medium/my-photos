import SwiftData
import SwiftUI

@ModelActor
actor DayStore {
    func get() -> [DateTakenDay] {
        let sort = SortDescriptor(\DateTakenDay.key)
        let descriptor = FetchDescriptor<DateTakenDay>(sortBy: [sort])
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return [] }
        return results
    }
    func get(_ id: UUID?) -> DateTakenDay? {
        guard let id else { return nil }
        
        let predicate = #Predicate<DateTakenDay> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenDay>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    func get(_ parent: DateTakenMonth, _ day: Int) -> DateTakenDay? {
        let key = DateTakenDay.key(parent, day)
        let predicate = #Predicate<DateTakenDay> { $0.key == key }
        let descriptor = FetchDescriptor<DateTakenDay>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }

    func findOrCreate(_ parent: DateTakenMonth, _ day: Int) throws
        -> DateTakenDay
    {
        if let existing = get(parent, day) { return existing }
        return try create(parent, day)
    }

    @discardableResult
    func create(_ parent: DateTakenMonth, _ day: Int) throws -> DateTakenDay {
        let newItem = DateTakenDay(parent, day)

        try insert(newItem)
        return newItem
    }

    func insert(_ item: DateTakenDay) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    func insert(_ items: [DateTakenDay]) throws {
        for item in items { modelContext.insert(item) }
        try modelContext.save()
    }

    @discardableResult
    func update(_ item: DateTakenDay, _ day: Int) throws -> DateTakenDay {
        item.day = day
        try modelContext.save()
        return item
    }

    func delete(_ item: DateTakenDay) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    func delete(_ items: [DateTakenDay]) throws {
        guard !items.isEmpty else { return }

        for item in items { modelContext.delete(item) }
        try modelContext.save()
    }

    func ensure(_ parentId: UUID?, _ day: Int?) throws -> UUID? {
        guard let parentId else { return nil }
        guard let parent = getParent(parentId) else { return nil }
        guard let day else { return nil }

        let ensured = try findOrCreate(parent, day)
        return ensured.id
    }
    func ensure(_ parentId: UUID?, _ days: [Int]) -> [UUID] {
        guard let parentId else { return [] }

        var result: [UUID] = []
        result.reserveCapacity(days.count)

        for day in days {
            if let ensured = try? ensure(parentId, day) {
                result.append(ensured)
            }
        }

        return result
    }

    private func getParent(_ id: UUID) -> DateTakenMonth? {
        let predicate = #Predicate<DateTakenMonth> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
}
