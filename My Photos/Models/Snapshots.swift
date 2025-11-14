import Foundation

enum Snapshot: Identifiable, Hashable {
    case album(AlbumSnapshot)
    case person(PersonSnapshot)
    case event(EventSnapshot)
    case tag(TagSnapshot)

    var id: UUID {
        switch self {
        case .album(let album): return album.id
        case .person(let person): return person.id
        case .event(let event): return event.id
        case .tag(let tag): return tag.id
        }
    }
}

struct AlbumSnapshot: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct PersonSnapshot: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct EventSnapshot: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct TagSnapshot: Identifiable, Hashable {
    let id: UUID
    let name: String
}
