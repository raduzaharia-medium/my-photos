import SwiftData
import SwiftUI

final class AlbumStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func get(_ album: String) -> Album? {
        let key = "\(album)"
        let descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.key == key }
        )

        return (try? context.fetch(descriptor))?.first
    }

    @discardableResult
    func create(name: String) throws -> Album {
        let album = Album(name)

        context.insert(album)
        try context.save()

        return album
    }

    @discardableResult
    func update(_ album: Album, name: String) throws -> Album {
        guard let album = context.model(for: album.id) as? Album else {
            throw StoreError.notFound
        }

        album.name = name
        try context.save()

        return album
    }

    func delete(_ album: Album) throws {
        guard let album = context.model(for: album.id) as? Album else {
            throw StoreError.notFound
        }

        context.delete(album)
        try context.save()
    }

    func delete(_ albums: [Album]) throws {
        guard !albums.isEmpty else { return }

        for album in albums {
            guard let album = context.model(for: album.id) as? Album else {
                throw StoreError.notFound
            }

            context.delete(album)
        }

        try context.save()
    }

    func ensure(_ album: String?) throws -> Album? {
        guard let album else { return nil }
        let ensured = try findOrCreate(album)

        return ensured
    }

    func ensure(_ albums: [String]) -> [Album] {
        var result: [Album] = []

        for album in albums {
            if let ensured = try? ensure(album) {
                result.append(ensured)
            }
        }

        return result
    }

    private func findOrCreate(_ album: String) throws -> Album {
        if let existing = get(album) { return existing }
        let newNode = Album(album)

        context.insert(newNode)
        try context.save()
        return newNode
    }
}
