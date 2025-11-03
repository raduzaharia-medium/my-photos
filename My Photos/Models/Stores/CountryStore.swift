import SwiftData
import SwiftUI

final class CountryStore {
    private let context: ModelContext
    private var cache: [String: PlaceCountry] = [:]

    init(context: ModelContext) {
        self.context = context
    }

    func get() -> [PlaceCountry] {
        let sort = SortDescriptor(\PlaceCountry.key)
        let descriptor = FetchDescriptor<PlaceCountry>(sortBy: [sort])

        guard let results = try? context.fetch(descriptor) else { return [] }
        return results
    }
    func get(_ name: String) -> PlaceCountry? {
        let key = PlaceCountry.key(name)
        if let cached = cache[key] { return cached }

        let predicate = #Predicate<PlaceCountry> { item in item.key == key }
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        cache[key] = fetched
        return fetched
    }

    func findOrCreate(_ name: String) throws -> PlaceCountry {
        if let existing = get(name) { return existing }
        return try create(name)
    }

    @discardableResult
    func create(_ name: String) throws -> PlaceCountry {
        let newItem = PlaceCountry(name)

        try insert(newItem)
        return newItem
    }

    func insert(_ item: PlaceCountry) throws {
        context.insert(item)
        try context.save()
        cache[item.key] = item
    }
    func insert(_ items: [PlaceCountry]) throws {
        for item in items {
            context.insert(item)
            cache[item.key] = item
        }

        try context.save()
    }

    @discardableResult
    func update(_ item: PlaceCountry, name: String) throws -> PlaceCountry {
        item.country = name
        try context.save()
        cache[item.key] = item

        try context.save()
        return item
    }

    func delete(_ item: PlaceCountry) throws {
        cache[item.key] = nil
        context.delete(item)

        try context.save()
    }
    func delete(_ items: [PlaceCountry]) throws {
        guard !items.isEmpty else { return }

        for item in items {
            cache[item.key] = nil
            context.delete(item)
        }

        try context.save()
    }

    func ensure(_ name: String?) throws -> PlaceCountry? {
        guard let name else { return nil }
        let ensured = try findOrCreate(name)

        return ensured
    }
    func ensure(_ names: [String]) -> [PlaceCountry] {
        var result: [PlaceCountry] = []
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
