import SwiftData
import SwiftUI

@ModelActor
actor CountryStore {
    func get() -> [PlaceCountry] {
        let sort = SortDescriptor(\PlaceCountry.key)
        let descriptor = FetchDescriptor<PlaceCountry>(sortBy: [sort])
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return [] }
        return results
    }
    func get(_ name: String) -> PlaceCountry? {
        let key = PlaceCountry.key(name)
        let predicate = #Predicate<PlaceCountry> { item in item.key == key }
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

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
        modelContext.insert(item)
        try modelContext.save()
    }
    func insert(_ items: [PlaceCountry]) throws {
        for item in items { modelContext.insert(item) }
        try modelContext.save()
    }

    @discardableResult
    func update(_ item: PlaceCountry, name: String) throws -> PlaceCountry {
        item.country = name
        try modelContext.save()
        return item
    }

    func delete(_ item: PlaceCountry) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    func delete(_ items: [PlaceCountry]) throws {
        guard !items.isEmpty else { return }

        for item in items { modelContext.delete(item) }
        try modelContext.save()
    }

    func ensure(_ name: String?) throws -> UUID? {
        guard let name else { return nil }
        let ensured = try findOrCreate(name)

        return ensured.id
    }
    func ensure(_ names: [String]) -> [UUID] {
        var result: [UUID] = []
        result.reserveCapacity(names.count)

        for name in names {
            if let ensured = try? ensure(name) { result.append(ensured) }
        }

        return result
    }
}
