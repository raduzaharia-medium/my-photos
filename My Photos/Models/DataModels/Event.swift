import Foundation
import SwiftData

@Model
final class Event: Identifiable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var name: String

    @Relationship(inverse: \Photo.event) var photos: [Photo] = []

    init(_ name: String) {
        self.name = name
        self.key = name
    }

    static func == (left: Event, right: Event) -> Bool {
        left.key == right.key
    }
}

extension Event {
    static let icon: String = "sparkles"
}
