import SwiftData
import SwiftUI

final class AlbumStore {
    private let context: ModelContext
    private var cache: [String: Album] = [:]

    init(context: ModelContext) {
        self.context = context
    }

    func get() -> [Album] {
        let sort = SortDescriptor(\Album.key)
        let descriptor = FetchDescriptor<Album>(sortBy: [sort])

        guard let results = try? context.fetch(descriptor) else { return [] }
        return results
    }
    func get(_ name: String) -> Album? {
        let key = Album.key(name)
        if let cached = cache[key] { return cached }

        let predicate = #Predicate<Album> { album in album.key == key }
        let descriptor = FetchDescriptor<Album>(predicate: predicate)

        guard let results = try? context.fetch(descriptor) else { return nil }
        guard let fetched = results.first else { return nil }

        cache[key] = fetched
        return fetched
    }
    
    func findOrCreate(_ name: String) throws -> Album {
        if let existing = get(name) { return existing }
        return try create(name)
    }

    @discardableResult
    func create(_ name: String) throws -> Album {
        let newItem = Album(name)

        try insert(newItem)
        return newItem
    }
    
    func insert(_ item: Album) throws {
        context.insert(item)
        try context.save()
        cache[item.key] = item
    }
    func insert(_ items: [Album]) throws {
        for item in items {
            context.insert(item)
            cache[item.key] = item
        }

        try context.save()
    }

    @discardableResult
    func update(_ album: Album, name: String) throws -> Album {
        album.name = name
        try context.save()
        cache[album.key] = album

        try context.save()
        return album
    }

    func delete(_ item: Album) throws {
        cache[item.key] = nil
        context.delete(item)
        
        try context.save()
    }
    func delete(_ items: [Album]) throws {
        guard !items.isEmpty else { return }

        for item in items {
            cache[item.key] = nil
            context.delete(item)
        }

        try context.save()
    }

    func ensure(_ name: String?) throws -> Album? {
        guard let name else { return nil }
        let ensured = try findOrCreate(name)
        
        return ensured
    }
    func ensure(_ names: [String]) -> [Album] {
        var result: [Album] = []
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
