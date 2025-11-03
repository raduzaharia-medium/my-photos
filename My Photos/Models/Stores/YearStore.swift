import SwiftData
import SwiftUI

final class YearStore {
    private let context: ModelContext
    private var cache: [String: DateTakenYear] = [:]

    init(context: ModelContext) {
        self.context = context
    }

    func get() -> [DateTakenYear] {
        let sort = SortDescriptor(\DateTakenYear.key)
        let descriptor = FetchDescriptor<DateTakenYear>(sortBy: [sort])

        guard let results = try? context.fetch(descriptor) else { return [] }
        return results
    }
    func get(_ year: Int) -> DateTakenYear? {
        let key = DateTakenYear.key(year)
        if let cached = cache[key] { return cached }

        let predicate = #Predicate<DateTakenYear> { $0.key == key }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        cache[key] = fetched
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
        context.insert(item)
        try context.save()
        cache[item.key] = item
    }
    func insert(_ items: [DateTakenYear]) throws {
        for item in items {
            context.insert(item)
            cache[item.key] = item
        }

        try context.save()
    }

    @discardableResult
    func update(_ item: DateTakenYear, year: Int) throws
        -> DateTakenYear
    {
        item.year = year
        try context.save()
        cache[item.key] = item

        try context.save()
        return item
    }

    func delete(_ item: DateTakenYear) throws {
        cache[item.key] = nil
        context.delete(item)

        try context.save()
    }
    func delete(_ items: [DateTakenYear]) throws {
        guard !items.isEmpty else { return }

        for item in items {
            cache[item.key] = nil
            context.delete(item)
        }

        try context.save()
    }

    func ensure(_ year: Int?) throws -> DateTakenYear? {
        guard let year else { return nil }
        let ensured = try findOrCreate(year)

        return ensured
    }
    func ensure(_ years: [Int]) -> [DateTakenYear] {
        var result: [DateTakenYear] = []
        result.reserveCapacity(years.count)

        for year in years {
            if let ensured = try? ensure(year) { result.append(ensured) }
        }

        return result
    }

    func clearCache() {
        cache.removeAll()
    }
}
