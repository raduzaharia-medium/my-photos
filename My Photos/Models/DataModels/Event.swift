import Foundation
import SwiftData

@Model
final class Event: Identifiable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var name: String

    @Relationship(inverse: \Photo.events) var photos: [Photo] = []

    init(_ name: String) {
        self.name = name
        self.key = Event.key(name)
    }

    static func == (left: Event, right: Event) -> Bool {
        left.key == right.key
    }
    
    static func key(_ name: String) -> String { name }
}

extension Event {
    static let icon: String = "sparkles"
}
