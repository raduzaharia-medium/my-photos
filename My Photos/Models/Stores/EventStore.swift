import SwiftData
import SwiftUI

@ModelActor
actor EventStore {
    func get() -> [Event] {
        let sort = SortDescriptor(\Event.key)
        let descriptor = FetchDescriptor<Event>(sortBy: [sort])
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return [] }
        return results
    }
    func get(_ id: UUID) -> Event? {
        let predicate = #Predicate<Event> { album in album.id == id }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    func get(_ name: String) -> Event? {
        let key = Event.key(name)
        let predicate = #Predicate<Event> { $0.key == key }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }

    @discardableResult
    func create(_ name: String) throws -> UUID {
        let newItem = try createInternal(name)
        return newItem.id
    }

    func insert(_ item: Event) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    func insert(_ items: [Event]) throws {
        for item in items { modelContext.insert(item) }
        try modelContext.save()
    }

    func update(_ id: UUID, name: String) throws {
        let item = get(id)
        guard let item else { throw DataStoreError.invalidPredicate }

        item.name = name
        try modelContext.save()
    }

    func delete(_ id: UUID) throws {
        let item = get(id)
        guard let item else { return }

        modelContext.delete(item)
        try modelContext.save()
    }
    func delete(_ ids: [UUID]) throws {
        guard !ids.isEmpty else { return }

        for item in ids {
            let item = get(item)
            guard let item else { continue }

            modelContext.delete(item)
        }
        
        try modelContext.save()
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

    private func findOrCreate(_ name: String) throws -> Event {
        if let existing = get(name) { return existing }
        return try createInternal(name)
    }

    private func createInternal(_ name: String) throws -> Event {
        let newItem = Event(name)

        try insert(newItem)
        return newItem
    }
}
