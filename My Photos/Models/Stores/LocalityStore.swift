import SwiftData
import SwiftUI

@ModelActor
actor LocalityStore {
    func get() -> [PlaceLocality] {
        let sort = SortDescriptor(\PlaceLocality.key)
        let descriptor = FetchDescriptor<PlaceLocality>(sortBy: [sort])
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return [] }
        return results
    }
    func get(_ id: UUID?) -> PlaceLocality? {
        guard let id else { return nil }
        
        let predicate = #Predicate<PlaceLocality> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceLocality>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    func get(_ parent: PlaceCountry, _ name: String) -> PlaceLocality? {
        let key = PlaceLocality.key(parent, name)
        let predicate = #Predicate<PlaceLocality> { $0.key == key }
        let descriptor = FetchDescriptor<PlaceLocality>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

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
        modelContext.insert(item)
        try modelContext.save()
    }
    func insert(_ items: [PlaceLocality]) throws {
        for item in items { modelContext.insert(item) }
        try modelContext.save()
    }

    @discardableResult
    func update(_ item: PlaceLocality, _ name: String) throws
        -> PlaceLocality
    {
        item.locality = name
        try modelContext.save()
        return item
    }

    func delete(_ item: PlaceLocality) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
    func delete(_ items: [PlaceLocality]) throws {
        guard !items.isEmpty else { return }

        for item in items { modelContext.delete(item) }
        try modelContext.save()
    }

    func ensure(_ parentId: UUID?, _ name: String?) throws -> UUID? {
        guard let parentId else { return nil }
        guard let parent = getParent(parentId) else { return nil }
        guard let name else { return nil }
        let ensured = try findOrCreate(parent, name)

        return ensured.id
    }
    func ensure(_ parentId: UUID?, _ names: [String]) -> [UUID] {
        guard let parentId else { return [] }

        var result: [UUID] = []
        result.reserveCapacity(names.count)

        for name in names {
            if let ensured = try? ensure(parentId, name) {
                result.append(ensured)
            }
        }

        return result
    }
    
    private func getParent(_ id: UUID) -> PlaceCountry? {
        let predicate = #Predicate<PlaceCountry> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }

}
