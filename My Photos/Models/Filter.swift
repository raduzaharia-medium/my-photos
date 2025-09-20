enum Filter: String, Codable, Hashable, CaseIterable, Identifiable {
    case all = "all"
    case favorites = "favorites"
    case recent = "recent"
    case edited = "edited"

    var id: String { rawValue }
}

extension Filter {
    var name: String {
        switch self {
        case .all: "All Photos"
        case .favorites: "Favorites"
        case .recent: "Recent"
        case .edited: "Edited"
        }
    }

    var icon: String {
        switch self {
        case .all: "rectangle.grid.2x2"
        case .favorites: "star.fill"
        case .recent: "clock"
        case .edited: "wand.and.stars"
        }
    }
}
