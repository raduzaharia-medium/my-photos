import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupPersonHandlers(
        modalPresenter: ModalService,
        notifier: NotificationService,
        confirmer: ConfirmationService,
        personStore: PersonStore
    ) -> some View {
        let personEditorPresenter = PersonEditorPresenter(
            modalPresenter: modalPresenter
        )
        let deletePersonPresenter = DeletePersonPresenter(confirmer: confirmer)

        let edit: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let person = note.object as? Person else { return }
            guard let name = note.userInfo?["name"] as? String else { return }

            do {
                try await personStore.update(person.id, name: name)
                notifier.show("Person updated", .success)
            } catch {
                notifier.show("Could not update person", .error)
            }
        }
        let create: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let name = note.object as? String else { return }

            do {
                try await personStore.create(name)
                notifier.show("Person created", .success)
            } catch {
                notifier.show("Could not create person", .error)
            }
        }
        let delete: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let person = note.object as? Person else { return }

            do {
                try await personStore.delete(person.id)
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
                notifier.show("People deleted", .success)
            } catch {
                notifier.show("Could not delete people", .error)
            }
        }
        let showCreator: (NotificationCenter.Publisher.Output) -> Void = {
            _ in
            personEditorPresenter.show(nil)
        }
        let showEditor: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let person = note.object as? Person else { return }
            personEditorPresenter.show(person)
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
            .onReceive(NotificationCenter.default.publisher(for: .editPerson)) {
                note in Task { await edit(note) }
            }
            .onReceive(NotificationCenter.default.publisher(for: .createPerson))
        { note in Task { await create(note) } }
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
