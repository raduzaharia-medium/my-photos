enum Filter: String, Codable, Hashable, CaseIterable, Identifiable {
    case all = "all"
    case favorites = "favorites"
    case recent = "recent"
    case edited = "edited"
    case selected = "selected"

    var id: String { rawValue }
}

extension Filter {
    var name: String {
        switch self {
        case .all: "All Photos"
        case .favorites: "Favorites"
        case .recent: "Recent Photos"
        case .edited: "Edited Photos"
        case .selected: "Selected Photos"
        }
    }

    var icon: String {
        switch self {
        case .all: "rectangle.grid.2x2"
        case .favorites: "star.fill"
        case .recent: "clock"
        case .edited: "wand.and.stars"
        case .selected: "checkmark.circle.fill"
        }
    }
}
