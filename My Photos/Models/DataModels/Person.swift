import Foundation
import SwiftData

@Model
final class Person: Identifiable, Hashable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var name: String

    @Relationship(inverse: \Photo.people) var photos: [Photo] = []

    init(_ name: String) {
        self.name = name
        self.key = Person.key(name)
    }

    static func == (left: Person, right: Person) -> Bool {
        left.key == right.key
    }
    
    static func key(_ name: String) -> String { name }
}

extension Person {
    static let icon: String = "person"
}
