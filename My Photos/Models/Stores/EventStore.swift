import SwiftData
import SwiftUI

final class EventStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func create(name: String) throws -> Event {
        let event = Event(name)

        context.insert(event)
        try context.save()

        return event
    }

    @discardableResult
    func update(_ event: Event, name: String) throws -> Event {
        guard let event = context.model(for: event.id) as? Event else {
            throw StoreError.notFound
        }

        event.name = name
        try context.save()

        return event
    }

    func delete(_ event: Event) throws {
        guard let event = context.model(for: event.id) as? Event else {
            throw StoreError.notFound
        }

        context.delete(event)
        try context.save()
    }

    func delete(_ events: [Event]) throws {
        guard !events.isEmpty else { return }

        for event in events {
            guard let event = context.model(for: event.id) as? Event else {
                throw StoreError.notFound
            }

            context.delete(event)
        }

        try context.save()
    }
}
