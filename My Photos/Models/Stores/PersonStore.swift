import SwiftData
import SwiftUI

final class PersonStore {
    private let context: ModelContext
    private var cache: [String: Person] = [:]

    init(context: ModelContext) {
        self.context = context
    }

    func get() -> [Person] {
        let sort = SortDescriptor(\Person.key)
        let descriptor = FetchDescriptor<Person>(sortBy: [sort])

        guard let results = try? context.fetch(descriptor) else { return [] }
        return results
    }
    func get(_ name: String) -> Person? {
        let key = Person.key(name)
        if let cached = cache[key] { return cached }

        let predicate = #Predicate<Person> { $0.key == key }
        let descriptor = FetchDescriptor<Person>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        cache[key] = fetched
        return fetched
    }

    func findOrCreate(_ name: String) throws -> Person {
        if let existing = get(name) { return existing }
        return try create(name)
    }

    @discardableResult
    func create(_ name: String) throws -> Person {
        let newItem = Person(name)

        try insert(newItem)
        return newItem
    }

    func insert(_ item: Person) throws {
        context.insert(item)
        try context.save()
        cache[item.key] = item
    }
    func insert(_ items: [Person]) throws {
        for item in items {
            context.insert(item)
            cache[item.key] = item
        }

        try context.save()
    }

    @discardableResult
    func update(_ item: Person, name: String) throws -> Person {
        item.name = name
        try context.save()
        cache[item.key] = item

        try context.save()
        return item
    }

    func delete(_ item: Person) throws {
        cache[item.key] = nil
        context.delete(item)

        try context.save()
    }
    func delete(_ items: [Person]) throws {
        guard !items.isEmpty else { return }

        for item in items {
            cache[item.key] = nil
            context.delete(item)
        }

        try context.save()
    }

    func ensure(_ name: String?) throws -> Person? {
        guard let name else { return nil }
        let ensured = try findOrCreate(name)

        return ensured
    }
    func ensure(_ names: [String]) -> [Person] {
        var result: [Person] = []
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
