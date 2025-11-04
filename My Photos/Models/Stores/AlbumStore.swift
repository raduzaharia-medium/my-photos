import SwiftData
import SwiftUI

@ModelActor
actor AlbumStore {
    func get() -> [Album] {
        let sort = SortDescriptor(\Album.key)
        let descriptor = FetchDescriptor<Album>(sortBy: [sort])
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return [] }
        return results
    }
    func get(_ id: UUID) -> Album? {
        let predicate = #Predicate<Album> { album in album.id == id }
        let descriptor = FetchDescriptor<Album>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    func get(_ name: String) -> Album? {
        let key = Album.key(name)
        let predicate = #Predicate<Album> { album in album.key == key }
        let descriptor = FetchDescriptor<Album>(predicate: predicate)
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

    func insert(_ item: Album) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    func insert(_ items: [Album]) throws {
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

    private func createInternal(_ name: String) throws -> Album {
        let newItem = Album(name)

        try insert(newItem)
        return newItem
    }

    private func findOrCreate(_ name: String) throws -> Album {
        if let existing = get(name) { return existing }
        return try createInternal(name)
    }
}
