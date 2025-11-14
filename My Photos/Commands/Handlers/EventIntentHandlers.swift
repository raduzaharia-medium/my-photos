import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupEventHandlers(
        presentationState: PresentationState,
        modalPresenter: ModalService,
        notifier: NotificationService,
        confirmer: ConfirmationService,
        eventStore: EventStore
    ) -> some View {
        let deleteEventPresenter = DeleteEventPresenter(confirmer: confirmer)

        let delete: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let event = note.object as? Event else { return }

            do {
                try await eventStore.delete(event.id)
                presentationState.photoFilter = []

                notifier.show("Event deleted", .success)
            } catch {
                notifier.show("Could not delete event", .error)
            }
        }
        let deleteMany: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let events = note.object as? [Event] else { return }

            do {
                try await eventStore.delete(events.map(\.id))
                presentationState.photoFilter = []

                notifier.show("Events deleted", .success)
            } catch {
                notifier.show("Could not delete events", .error)
            }
        }
        let showCreator: (NotificationCenter.Publisher.Output) -> Void = { _ in
            modalPresenter.show(onDismiss: {}) { EventEditorSheet(nil) }
        }
        let showEditor: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let event = note.object as? Event else { return }
            modalPresenter.show(onDismiss: {}) {
                EventEditorSheet(event)
            }
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
                NotificationCenter.default.publisher(for: .deleteEvent)
            ) { note in
                Task { await delete(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteEvents)
            ) { note in
                Task { await deleteMany(note) }
            }
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
