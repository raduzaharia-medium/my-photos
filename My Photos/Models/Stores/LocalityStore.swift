import SwiftData
import SwiftUI

final class LocalityStore {
    private let context: ModelContext
    private var cache: [String: PlaceLocality] = [:]

    init(context: ModelContext) {
        self.context = context
    }

    func get() -> [PlaceLocality] {
        let sort = SortDescriptor(\PlaceLocality.key)
        let descriptor = FetchDescriptor<PlaceLocality>(sortBy: [sort])

        guard let results = try? context.fetch(descriptor) else { return [] }
        return results
    }
    func get(_ parent: PlaceCountry, _ name: String) -> PlaceLocality? {
        let key = PlaceLocality.key(parent, name)
        if let cached = cache[key] { return cached }

        let predicate = #Predicate<PlaceLocality> { $0.key == key }
        let descriptor = FetchDescriptor<PlaceLocality>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        cache[key] = fetched
        return fetched
    }

    func findOrCreate(_ parent: PlaceCountry, _ name: String) throws
        -> PlaceLocality
    {
        if let existing = get(parent, name) { return existing }
        return try create(parent, name)
    }

    @discardableResult
    func create(_ parent: PlaceCountry, _ name: String) throws
        -> PlaceLocality
    {
        let newItem = PlaceLocality(parent, name)

        try insert(newItem)
        return newItem
    }

    func insert(_ item: PlaceLocality) throws {
        context.insert(item)
        try context.save()
        cache[item.key] = item
    }
    func insert(_ items: [PlaceLocality]) throws {
        for item in items {
            context.insert(item)
            cache[item.key] = item
        }

        try context.save()
    }

    @discardableResult
    func update(_ item: PlaceLocality, _ name: String) throws
        -> PlaceLocality
    {
        item.locality = name
        try context.save()
        cache[item.key] = item

        try context.save()
        return item
    }

    func delete(_ item: PlaceLocality) throws {
        cache[item.key] = nil
        context.delete(item)

        try context.save()
    }
    func delete(_ items: [PlaceLocality]) throws {
        guard !items.isEmpty else { return }

        for item in items {
            cache[item.key] = nil
            context.delete(item)
        }

        try context.save()
    }

    func ensure(_ parent: PlaceCountry?, _ name: String?) throws
        -> PlaceLocality?
    {
        guard let parent else { return nil }
        guard let name else { return nil }
        let ensured = try findOrCreate(parent, name)

        return ensured
    }
    func ensure(_ parent: PlaceCountry?, _ names: [String]) -> [PlaceLocality] {
        guard let parent else { return [] }

        var result: [PlaceLocality] = []
        result.reserveCapacity(names.count)

        for name in names {
            if let ensured = try? ensure(parent, name) {
                result.append(ensured)
            }
        }

        return result
    }

    func clearCache() {
        cache.removeAll()
    }
}
