import Foundation
import SwiftData

@Model
final class Person: Identifiable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var name: String

    @Relationship(inverse: \Photo.people) var photos: [Photo] = []

    init(_ name: String) {
        self.name = name
        self.key = name
    }

    static func == (left: Person, right: Person) -> Bool {
        left.key == right.key
    }
}

extension Person {
    static let icon: String = "person"
}
