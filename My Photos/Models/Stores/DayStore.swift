import SwiftData
import SwiftUI

final class DayStore {
    private let context: ModelContext
    private var cache: [String: DateTakenDay] = [:]

    init(context: ModelContext) {
        self.context = context
    }

    func get() -> [DateTakenDay] {
        let sort = SortDescriptor(\DateTakenDay.key)
        let descriptor = FetchDescriptor<DateTakenDay>(sortBy: [sort])

        guard let results = try? context.fetch(descriptor) else { return [] }
        return results
    }
    func get(_ parent: DateTakenMonth, _ day: Int) -> DateTakenDay? {
        let key = DateTakenDay.key(parent, day)
        if let cached = cache[key] { return cached }

        let predicate = #Predicate<DateTakenDay> { $0.key == key }
        let descriptor = FetchDescriptor<DateTakenDay>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        cache[key] = fetched
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
        context.insert(item)
        try context.save()
        cache[item.key] = item
    }
    func insert(_ items: [DateTakenDay]) throws {
        for item in items {
            context.insert(item)
            cache[item.key] = item
        }

        try context.save()
    }

    @discardableResult
    func update(_ item: DateTakenDay, _ day: Int) throws -> DateTakenDay {
        item.day = day
        try context.save()
        cache[item.key] = item

        try context.save()
        return item
    }

    func delete(_ item: DateTakenDay) throws {
        cache[item.key] = nil
        context.delete(item)

        try context.save()
    }
    func delete(_ items: [DateTakenDay]) throws {
        guard !items.isEmpty else { return }

        for item in items {
            cache[item.key] = nil
            context.delete(item)
        }

        try context.save()
    }

    func ensure(_ parent: DateTakenMonth?, _ day: Int?) throws -> DateTakenDay? {
        guard let parent else { return nil }
        guard let day else { return nil }
        let ensured = try findOrCreate(parent, day)

        return ensured
    }
    func ensure(_ parent: DateTakenMonth?, _ days: [Int]) -> [DateTakenDay] {
        guard let parent else { return [] }
        
        var result: [DateTakenDay] = []
        result.reserveCapacity(days.count)

        for day in days {
            if let ensured = try? ensure(parent, day) {
                result.append(ensured)
            }
        }

        return result
    }

    func clearCache() {
        cache.removeAll()
    }
}
