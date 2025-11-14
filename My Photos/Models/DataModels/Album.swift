import Foundation
import SwiftData

@Model
final class Album: Identifiable, Hashable, Equatable, Comparable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var name: String

    @Relationship(inverse: \Photo.albums) var photos: [Photo] = []

    init(_ name: String) {
        self.name = name
        self.key = Album.key(name)
    }

    static func == (left: Album, right: Album) -> Bool { left.key == right.key }
    static func < (lhs: Album, rhs: Album) -> Bool { lhs.name < rhs.name }

    static func key(_ name: String) -> String { name }
}

extension Album {
    static let icon: String = "photo.on.rectangle"
}
