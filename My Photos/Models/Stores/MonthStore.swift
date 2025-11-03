import SwiftData
import SwiftUI

final class MonthStore {
    private let context: ModelContext
    private var cache: [String: DateTakenMonth] = [:]

    init(context: ModelContext) {
        self.context = context
    }

    func get() -> [DateTakenMonth] {
        let sort = SortDescriptor(\DateTakenMonth.key)
        let descriptor = FetchDescriptor<DateTakenMonth>(sortBy: [sort])

        guard let results = try? context.fetch(descriptor) else { return [] }
        return results
    }
    func get(_ parent: DateTakenYear, _ month: Int) -> DateTakenMonth? {
        let key = DateTakenMonth.key(parent, month)
        if let cached = cache[key] { return cached }

        let predicate = #Predicate<DateTakenMonth> { $0.key == key }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        cache[key] = fetched
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
        context.insert(item)
        try context.save()
        cache[item.key] = item
    }
    func insert(_ items: [DateTakenMonth]) throws {
        for item in items {
            context.insert(item)
            cache[item.key] = item
        }

        try context.save()
    }

    @discardableResult
    func update(_ item: DateTakenMonth, _ month: Int) throws
        -> DateTakenMonth
    {
        item.month = month
        try context.save()
        cache[item.key] = item

        try context.save()
        return item
    }

    func delete(_ item: DateTakenMonth) throws {
        cache[item.key] = nil
        context.delete(item)

        try context.save()
    }
    func delete(_ items: [DateTakenMonth]) throws {
        guard !items.isEmpty else { return }

        for item in items {
            cache[item.key] = nil
            context.delete(item)
        }

        try context.save()
    }

    func ensure(_ parent: DateTakenYear?, _ month: Int?) throws
        -> DateTakenMonth?
    {
        guard let parent else { return nil }
        guard let month else { return nil }
        let ensured = try findOrCreate(parent, month)

        return ensured
    }
    func ensure(_ parent: DateTakenYear?, _ months: [Int]) -> [DateTakenMonth] {
        guard let parent else { return [] }
        
        var result: [DateTakenMonth] = []
        result.reserveCapacity(months.count)

        for month in months {
            if let ensured = try? ensure(parent, month) {
                result.append(ensured)
            }
        }

        return result
    }

    func clearCache() {
        cache.removeAll()
    }
}
