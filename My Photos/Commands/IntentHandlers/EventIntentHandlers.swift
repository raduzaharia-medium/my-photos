import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupEventHandlers(
        modalPresenter: ModalService,
        notifier: NotificationService,
        confirmer: ConfirmationService,
        eventStore: EventStore
    ) -> some View {
        let eventEditorPresenter = EventEditorPresenter(
            modalPresenter: modalPresenter
        )
        let deleteEventPresenter = DeleteEventPresenter(confirmer: confirmer)

        let edit: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let event = note.object as? Event else { return }
            guard let name = note.userInfo?["name"] as? String else { return }

            do {
                try eventStore.update(event, name: name)
                notifier.show("Event updated", .success)
            } catch {
                notifier.show("Could not update event", .error)
            }
        }
        let create: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let name = note.object as? String else { return }

            do {
                try eventStore.create(name: name)
                notifier.show("Event created", .success)
            } catch {
                notifier.show("Could not create event", .error)
            }
        }
        let delete: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let event = note.object as? Event else { return }

            do {
                try eventStore.delete(event)
                notifier.show("Event deleted", .success)
            } catch {
                notifier.show("Could not delete event", .error)
            }
        }
        let deleteMany: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let events = note.object as? [Event] else { return }

            do {
                try eventStore.delete(events)
                notifier.show("Events deleted", .success)
            } catch {
                notifier.show("Could not delete events", .error)
            }
        }
        let showCreator: (NotificationCenter.Publisher.Output) -> Void = {
            _ in
            eventEditorPresenter.show(nil)
        }
        let showEditor: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let event = note.object as? Event else { return }
            eventEditorPresenter.show(event)
        }
        let showRemover: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let event = note.object as? Event else { return }
            deleteEventPresenter.show(event)
        }
        let showManyRemover: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let events = note.object as? [Event] else { return }
            deleteEventPresenter.show(events)
        }

        return
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .editEvent),
                perform: edit
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .createEvent),
                perform: create
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteEvent),
                perform: delete
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteEvents),
                perform: deleteMany
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestCreateEvent),
                perform: showCreator
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestEditEvent),
                perform: showEditor
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeleteEvent),
                perform: showRemover
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeleteEvents),
                perform: showManyRemover
            )
    }
}
