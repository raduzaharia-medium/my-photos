import Foundation
import SwiftData

enum TagKind: String, Codable, Hashable, CaseIterable, Identifiable {
    case person = "person"
    case event = "event"
    case custom = "custom"

    var id: String { rawValue }
}

extension TagKind {
    var title: String {
        switch self {
        case .person: "People"
        case .event: "Events"
        case .custom: "Tags"
        }
    }

    var icon: String {
        switch self {
        case .person: "person"
        case .event: "sparkles"
        case .custom: "tag"
        }
    }
}

@Model
final class Tag: Identifiable, Hashable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var name: String
    var kind: TagKind

    @Relationship(inverse: \Tag.parent) var children: [Tag] = []
    @Relationship var parent: Tag?
    @Relationship var photos: [Photo] = []

    public init(name: String, kind: TagKind, parent: Tag? = nil) {
        self.name = name
        self.kind = kind
        self.parent = parent
    }
}
