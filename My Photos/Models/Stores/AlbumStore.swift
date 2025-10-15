import SwiftData
import SwiftUI

final class AlbumStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
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
}
