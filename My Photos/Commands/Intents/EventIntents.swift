import SwiftUI

extension Notification.Name {
    static let requestCreateEvent = Notification.Name("requestCreateEvent")
    static let requestEditEvent = Notification.Name("requestEditEvent")
    static let requestDeleteEvent = Notification.Name("requestDeleteEvent")
    static let requestDeleteEvents = Notification.Name("requestDeleteEvents")

    static let deleteEvent = Notification.Name("deleteEvent")
    static let deleteEvents = Notification.Name("deleteEvents")
}

enum EventIntents {
    static func requestCreate() {
        NotificationCenter.default.post(name: .requestCreateEvent, object: nil)
    }
    static func requestEdit(_ event: Event) {
        NotificationCenter.default.post(name: .requestEditEvent, object: event)
    }
    static func requestDelete(_ event: Event) {
        NotificationCenter.default.post(name: .requestDeleteEvent, object: event)
    }
    static func requestDelete(_ events: [Event]) {
        NotificationCenter.default.post(
            name: .requestDeleteEvents,
            object: events
        )
    }

    static func delete(_ event: Event) {
        NotificationCenter.default.post(name: .deleteEvent, object: event)
    }
    static func delete(_ events: [Event]) {
        NotificationCenter.default.post(name: .deleteEvents, object: events)
    }
}
