import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupPersonHandlers(
        modalPresenter: ModalService,
        notifier: NotificationService,
        alerter: AlertService,
        personStore: PersonStore
    ) -> some View {
        let personEditorPresenter = PersonEditorPresenter(
            modalPresenter: modalPresenter
        )
        let deletePersonPresenter = DeletePersonPresenter(alerter: alerter)

        let edit: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let person = note.object as? Person else { return }
            guard let name = note.userInfo?["name"] as? String else { return }

            do {
                try personStore.update(person, name: name)
                notifier.show("Person updated", .success)
            } catch {
                notifier.show("Could not update person", .error)
            }
        }
        let create: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let name = note.object as? String else { return }

            do {
                try personStore.create(name: name)
                notifier.show("Person created", .success)
            } catch {
                notifier.show("Could not create person", .error)
            }
        }
        let delete: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let person = note.object as? Person else { return }

            do {
                try personStore.delete(person)
                notifier.show("Person deleted", .success)
            } catch {
                notifier.show("Could not delete person", .error)
            }
        }
        let deleteMany: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let people = note.object as? [Person] else { return }

            do {
                try personStore.delete(people)
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
            .onReceive(
                NotificationCenter.default.publisher(for: .editPerson),
                perform: edit
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .createPerson),
                perform: create
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .deletePerson),
                perform: delete
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .deletePeople),
                perform: deleteMany
            )
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
