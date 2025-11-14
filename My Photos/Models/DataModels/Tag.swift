import Foundation
import SwiftData

@Model
final class Tag: Identifiable, Hashable, Equatable, Comparable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var name: String

    @Relationship(deleteRule: .cascade, inverse: \Tag.parent) var children: [Tag] = []
    @Relationship var parent: Tag?
    @Relationship var photos: [Photo] = []

    public init(name: String, parent: Tag? = nil) {
        self.name = name
        self.key = Tag.key(parent, name)
        self.parent = parent
    }

    func descendant(of root: Tag) -> Bool {
        parent == root || parent?.descendant(of: root) == true
    }

    func flatten() -> [Tag] {
        [self] + children.flatMap { $0.flatten() }
    }
    
    static func == (left: Tag, right: Tag) -> Bool {
        left.key == right.key
    }
    static func < (lhs: Tag, rhs: Tag) -> Bool {
        lhs.key < rhs.key
    }

    static func key(_ parent: Tag?, _ name: String) -> String {
        "\(parent?.key ?? "root")-\(name)"
    }
}

extension Tag {
    static let icon: String = "tag"
}
