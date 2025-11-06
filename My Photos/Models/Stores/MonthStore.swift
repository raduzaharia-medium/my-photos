import SwiftData
import SwiftUI

@ModelActor
actor MonthStore {
    func get() -> [DateTakenMonth] {
        let sort = SortDescriptor(\DateTakenMonth.key)
        let descriptor = FetchDescriptor<DateTakenMonth>(sortBy: [sort])
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return [] }
        return results
    }
    func get(_ id: UUID?) -> DateTakenMonth? {
        guard let id else { return nil }
        
        let predicate = #Predicate<DateTakenMonth> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    func get(_ parent: DateTakenYear, _ month: Int) -> DateTakenMonth? {
        let key = DateTakenMonth.key(parent, month)
        let predicate = #Predicate<DateTakenMonth> { $0.key == key }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }

    func findOrCreate(_ parent: DateTakenYear, _ month: Int) throws
        -> DateTakenMonth
    {
        if let existing = get(parent, month) { return existing }
        return try create(parent, month)
    }

    @discardableResult
    func create(_ parent: DateTakenYear, _ month: Int) throws
        -> DateTakenMonth
    {
        let newItem = DateTakenMonth(parent, month)

        try insert(newItem)
        return newItem
    }

    func insert(_ item: DateTakenMonth) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    func insert(_ items: [DateTakenMonth]) throws {
        for item in items { modelContext.insert(item) }
        try modelContext.save()
    }

    @discardableResult
    func update(_ item: DateTakenMonth, _ month: Int) throws
        -> DateTakenMonth
    {
        item.month = month
        try modelContext.save()
        return item
    }

    func delete(_ item: DateTakenMonth) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    func delete(_ items: [DateTakenMonth]) throws {
        guard !items.isEmpty else { return }

        for item in items { modelContext.delete(item) }
        try modelContext.save()
    }

    func ensure(_ parentId: UUID?, _ month: Int?) throws -> UUID? {
        guard let parentId else { return nil }
        guard let parent = getParent(parentId) else { return nil }
        guard let month else { return nil }
        let ensured = try findOrCreate(parent, month)

        return ensured.id
    }
    func ensure(_ parentId: UUID?, _ months: [Int]) -> [UUID] {
        guard let parentId else { return [] }

        var result: [UUID] = []
        result.reserveCapacity(months.count)

        for month in months {
            if let ensured = try? ensure(parentId, month) {
                result.append(ensured)
            }
        }

        return result
    }
    
    private func getParent(_ id: UUID) -> DateTakenYear? {
        let predicate = #Predicate<DateTakenYear> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
}
