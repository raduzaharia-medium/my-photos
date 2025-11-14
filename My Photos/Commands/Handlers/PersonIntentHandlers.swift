import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupPersonHandlers(
        presentationState: PresentationState,
        modalPresenter: ModalService,
        notifier: NotificationService,
        confirmer: ConfirmationService,
        personStore: PersonStore
    ) -> some View {
        let deletePersonPresenter = DeletePersonPresenter(confirmer: confirmer)

        let delete: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let person = note.object as? Person else { return }

            do {
                try await personStore.delete(person.id)
                presentationState.photoFilter = []

                notifier.show("Person deleted", .success)
            } catch {
                notifier.show("Could not delete person", .error)
            }
        }
        let deleteMany: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let people = note.object as? [Person] else { return }

            do {
                try await personStore.delete(people.map(\.id))
                presentationState.photoFilter = []

                notifier.show("People deleted", .success)
            } catch {
                notifier.show("Could not delete people", .error)
            }
        }
        let showCreator: (NotificationCenter.Publisher.Output) -> Void = { _ in
            modalPresenter.show(onDismiss: {}) { PersonEditorSheet(nil) }
        }
        let showEditor: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let person = note.object as? Person else { return }
            modalPresenter.show(onDismiss: {}) { PersonEditorSheet(person) }
        }
        let showRemover: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let person = note.object as? Person else { return }
            deletePersonPresenter.show(person)
        }
        let showManyRemover: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let people = note.object as? [Person] else { return }
            deletePersonPresenter.show(people)
        }

        return
            self
            .onReceive(NotificationCenter.default.publisher(for: .deletePerson))
        { note in Task { await delete(note) } }
            .onReceive(NotificationCenter.default.publisher(for: .deletePeople))
        { note in Task { await deleteMany(note) } }
            .onReceive(
                NotificationCenter.default.publisher(for: .requestCreatePerson),
                perform: showCreator
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestEditPerson),
                perform: showEditor
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeletePerson),
                perform: showRemover
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeletePeople),
                perform: showManyRemover
            )
    }
}
