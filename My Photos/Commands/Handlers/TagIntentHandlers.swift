import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupTagHandlers(
        presentationState: PresentationState,
        modalPresenter: ModalService,
        notifier: NotificationService,
        confirmer: ConfirmationService,
        tagStore: TagStore
    ) -> some View {
        let editTagPresenter = TagEditorPresenter(
            modalPresenter: modalPresenter
        )
        let deleteTagPresenter = DeleteTagPresenter(confirmer: confirmer)

        let edit: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let tag = note.object as? Tag else { return }
            guard let name = note.userInfo?["name"] as? String else { return }
            let parent = note.userInfo?["parent"] as? Tag

            do {
                try await tagStore.update(tag.id, name, parent?.id)
                notifier.show("Tag updated", .success)
            } catch {
                notifier.show("Could not update tag", .error)
            }
        }
        let editById: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let tagId = note.object as? UUID else { return }
            let name = note.userInfo?["name"] as? String
            let parent = note.userInfo?["parent"] as? Tag

            do {
                try await tagStore.update(tagId, name, parent?.id)
                notifier.show("Tag updated", .success)
            } catch {
                notifier.show("Could not update tag", .error)
            }
        }
        let create: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let name = note.object as? String else { return }
            let parent = note.userInfo?["parent"] as? Tag

            do {
                try await tagStore.create(name, parent?.id)
                notifier.show("Tag created", .success)
            } catch {
                notifier.show("Could not create tag", .error)
            }
        }
        let delete: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let tag = note.object as? Tag else { return }

            do {
                try await tagStore.delete(tag.id)
                presentationState.photoFilter = []

                notifier.show("Tag deleted", .success)
            } catch {
                notifier.show("Could not delete tag", .error)
            }
        }
        let deleteMany: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let tags = note.object as? [Tag] else { return }

            do {
                try await tagStore.delete(tags.map(\.id))
                presentationState.photoFilter = []

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
                NotificationCenter.default.publisher(for: .editTag)
            ) { note in
                Task { await edit(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .editTagByID)
            ) { note in
                Task { await editById(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .createTag)
            ) { note in
                Task { await create(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteTag)
            ) { note in
                Task { await delete(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteTags)
            ) { note in
                Task { await deleteMany(note) }
            }
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
