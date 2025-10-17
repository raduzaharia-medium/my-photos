import Foundation
import SwiftData

@Model
final class Tag: Identifiable, Hashable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var name: String

    @Relationship(inverse: \Tag.parent) var children: [Tag] = []
    @Relationship var parent: Tag?
    @Relationship var photos: [Photo] = []

    public init(name: String, parent: Tag? = nil) {
        self.name = name
        self.key = "\(parent?.name ?? "root")-\(name)"
        self.parent = parent
    }

    func descendant(of root: Tag) -> Bool {
        parent == root || parent?.descendant(of: root) == true
    }
}

extension Tag {
    static let icon: String = "tag"
}
