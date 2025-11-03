import SwiftData
import SwiftUI

final class EventStore {
    private let context: ModelContext
    private var cache: [String: Event] = [:]

    init(context: ModelContext) {
        self.context = context
    }

    func get() -> [Event] {
        let sort = SortDescriptor(\Event.key)
        let descriptor = FetchDescriptor<Event>(sortBy: [sort])

        guard let results = try? context.fetch(descriptor) else { return [] }
        return results
    }
    func get(_ name: String) -> Event? {
        let key = Event.key(name)
        if let cached = cache[key] { return cached }

        let predicate = #Predicate<Event> { $0.key == key }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        cache[key] = fetched
        return fetched
    }

    func findOrCreate(_ name: String) throws -> Event {
        if let existing = get(name) { return existing }
        return try create(name)
    }

    @discardableResult
    func create(_ name: String) throws -> Event {
        let newItem = Event(name)

        try insert(newItem)
        return newItem
    }

    func insert(_ item: Event) throws {
        context.insert(item)
        try context.save()
        cache[item.key] = item
    }
    func insert(_ items: [Event]) throws {
        for item in items {
            context.insert(item)
            cache[item.key] = item
        }

        try context.save()
    }

    @discardableResult
    func update(_ item: Event, name: String) throws -> Event {
        item.name = name
        try context.save()
        cache[item.key] = item

        try context.save()
        return item
    }

    func delete(_ item: Event) throws {
        cache[item.key] = nil
        context.delete(item)

        try context.save()
    }
    func delete(_ items: [Event]) throws {
        guard !items.isEmpty else { return }

        for item in items {
            cache[item.key] = nil
            context.delete(item)
        }

        try context.save()
    }

    func ensure(_ name: String?) throws -> Event? {
        guard let name else { return nil }
        let ensured = try findOrCreate(name)

        return ensured
    }
    func ensure(_ names: [String]) -> [Event] {
        var result: [Event] = []
        result.reserveCapacity(names.count)

        for name in names {
            if let ensured = try? ensure(name) { result.append(ensured) }
        }

        return result
    }

    func clearCache() {
        cache.removeAll()
    }
}
