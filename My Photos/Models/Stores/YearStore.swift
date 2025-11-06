import SwiftData
import SwiftUI

@ModelActor
actor YearStore {
    func get() -> [DateTakenYear] {
        let sort = SortDescriptor(\DateTakenYear.key)
        let descriptor = FetchDescriptor<DateTakenYear>(sortBy: [sort])
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return [] }
        return results
    }
    func get(_ id: UUID?) -> DateTakenYear? {
        guard let id else { return nil }
        
        let predicate = #Predicate<DateTakenYear> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    func get(_ year: Int) -> DateTakenYear? {
        let key = DateTakenYear.key(year)
        let predicate = #Predicate<DateTakenYear> { $0.key == key }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }

    func findOrCreate(_ year: Int) throws -> DateTakenYear {
        if let existing = get(year) { return existing }
        return try create(year)
    }

    func create(_ year: Int) throws -> DateTakenYear {
        let newItem = DateTakenYear(year)

        try insert(newItem)
        return newItem
    }

    func insert(_ item: DateTakenYear) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    func insert(_ items: [DateTakenYear]) throws {
        for item in items { modelContext.insert(item) }
        try modelContext.save()
    }

    @discardableResult
    func update(_ item: DateTakenYear, year: Int) throws -> DateTakenYear {
        item.year = year
        try modelContext.save()
        return item
    }

    func delete(_ item: DateTakenYear) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    func delete(_ items: [DateTakenYear]) throws {
        guard !items.isEmpty else { return }

        for item in items { modelContext.delete(item) }
        try modelContext.save()
    }

    func ensure(_ year: Int?) throws -> UUID? {
        guard let year else { return nil }
        let ensured = try findOrCreate(year)

        return ensured.id
    }
    func ensure(_ years: [Int]) -> [UUID] {
        var result: [UUID] = []
        result.reserveCapacity(years.count)

        for year in years {
            if let ensured = try? ensure(year) { result.append(ensured) }
        }

        return result
    }
}
