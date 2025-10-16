import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupTagHandlers(
        modalPresenter: ModalService,
        notifier: NotificationService,
        alerter: AlertService,
        tagStore: TagStore
    ) -> some View {
        let editTagPresenter = TagEditorPresenter(
            modalPresenter: modalPresenter
        )
        let deleteTagPresenter = DeleteTagPresenter(alerter: alerter)

        let edit: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let tag = note.object as? Tag else { return }
            guard let name = note.userInfo?["name"] as? String else { return }
            let parent = note.userInfo?["parent"] as? Tag

            do {
                try tagStore.update(tag, name: name, parent: parent)
                notifier.show("Tag updated", .success)
            } catch {
                notifier.show("Could not update tag", .error)
            }
        }
        let create: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let name = note.object as? String else { return }
            let parent = note.userInfo?["parent"] as? Tag
           
            do {
                try tagStore.create(name: name, parent: parent)
                notifier.show("Tag created", .success)
            } catch {
                notifier.show("Could not create tag", .error)
            }
        }
        let delete: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let tag = note.object as? Tag else { return }

            do {
                try tagStore.delete(tag)
                notifier.show("Tag deleted", .success)
            } catch {
                notifier.show("Could not delete tag", .error)
            }
        }
        let deleteMany: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let tags = note.object as? [Tag] else { return }

            do {
                try tagStore.delete(tags)
                notifier.show("Tags deleted", .success)
            } catch {
                notifier.show("Could not delete tags", .error)
            }
        }
        let showTagCreator: (NotificationCenter.Publisher.Output) -> Void = {
            _ in
            editTagPresenter.show(nil)
        }
        let showTagEditor: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let tag = note.object as? Tag else { return }
            editTagPresenter.show(tag)
        }
        let showTagRemover: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let tag = note.object as? Tag else { return }
            deleteTagPresenter.show(tag)
        }
        let showTagsRemover: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let tags = note.object as? [Tag] else { return }
            deleteTagPresenter.show(tags)
        }

        return
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .editTag),
                perform: edit
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .createTag),
                perform: create
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteTag),
                perform: delete
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteTags),
                perform: deleteMany
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestCreateTag),
                perform: showTagCreator
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestEditTag),
                perform: showTagEditor
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeleteTag),
                perform: showTagRemover
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeleteTags),
                perform: showTagsRemover
            )
    }
}
