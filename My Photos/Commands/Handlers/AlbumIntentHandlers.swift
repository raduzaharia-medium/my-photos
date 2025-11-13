import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupAlbumHandlers(
        presentationState: PresentationState,
        modalPresenter: ModalService,
        notifier: NotificationService,
        confirmer: ConfirmationService,
        albumStore: AlbumStore
    ) -> some View {
        let deleteAlbumPresenter = DeleteAlbumPresenter(confirmer: confirmer)

        let edit: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let album = note.object as? Album else { return }
            guard let name = note.userInfo?["name"] as? String else { return }

            do {
                try await albumStore.update(album.id, name)
                notifier.show("Album updated", .success)
            } catch {
                notifier.show("Could not update album", .error)
            }
        }
        let create: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let name = note.object as? String else { return }

            do {
                try await albumStore.create(name)
                notifier.show("Album created", .success)
            } catch {
                notifier.show("Could not create album", .error)
            }
        }
        let delete: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let album = note.object as? Album else { return }

            do {
                try await albumStore.delete(album.id)
                presentationState.photoFilter = []

                notifier.show("Album deleted", .success)
            } catch {
                notifier.show("Could not delete album", .error)
            }
        }
        let deleteMany: (NotificationCenter.Publisher.Output) async -> Void = {
            note in
            guard let albums = note.object as? [Album] else { return }

            do {
                try await albumStore.delete(albums.map(\.id))
                presentationState.photoFilter = []

                notifier.show("Albums deleted", .success)
            } catch {
                notifier.show("Could not delete albums", .error)
            }
        }
        let showCreator: (NotificationCenter.Publisher.Output) -> Void = { _ in
            modalPresenter.show(onDismiss: {}) { AlbumEditorSheet(nil) }
        }
        let showEditor: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let album = note.object as? Album else { return }
            modalPresenter.show(onDismiss: {}) { AlbumEditorSheet(album) }
        }
        let showRemover: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let album = note.object as? Album else { return }
            deleteAlbumPresenter.show(album)
        }
        let showManyRemover: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let albums = note.object as? [Album] else { return }
            deleteAlbumPresenter.show(albums)
        }

        return
            self
            .onReceive(
                NotificationCenter.default.publisher(for: .editAlbum)
            ) { note in
                Task { await edit(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .createAlbum)
            ) { note in
                Task { await create(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteAlbum)
            ) { note in
                Task { await delete(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteAlbums)
            ) { note in
                Task { await deleteMany(note) }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .requestCreateAlbum),
                perform: showCreator
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestEditAlbum),
                perform: showEditor
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeleteAlbum),
                perform: showRemover
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .requestDeleteAlbums),
                perform: showManyRemover
            )
    }
}
