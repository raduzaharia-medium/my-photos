import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func setupAlbumHandlers(
        modalPresenter: ModalService,
        notifier: NotificationService,
        confirmer: ConfirmationService,
        albumStore: AlbumStore
    ) -> some View {
        let albumEditorPresenter = AlbumEditorPresenter(
            modalPresenter: modalPresenter
        )
        let deleteAlbumPresenter = DeleteAlbumPresenter(confirmer: confirmer)

        let edit: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let album = note.object as? Album else { return }
            guard let name = note.userInfo?["name"] as? String else { return }

            do {
                try albumStore.update(album, name: name)
                notifier.show("Album updated", .success)
            } catch {
                notifier.show("Could not update album", .error)
            }
        }
        let create: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let name = note.object as? String else { return }

            do {
                try albumStore.create(name: name)
                notifier.show("Album created", .success)
            } catch {
                notifier.show("Could not create album", .error)
            }
        }
        let delete: (NotificationCenter.Publisher.Output) -> Void = { note in
            guard let album = note.object as? Album else { return }

            do {
                try albumStore.delete(album)
                notifier.show("Album deleted", .success)
            } catch {
                notifier.show("Could not delete album", .error)
            }
        }
        let deleteMany: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let albums = note.object as? [Album] else { return }

            do {
                try albumStore.delete(albums)
                notifier.show("Albums deleted", .success)
            } catch {
                notifier.show("Could not delete albums", .error)
            }
        }
        let showCreator: (NotificationCenter.Publisher.Output) -> Void = {
            _ in
            albumEditorPresenter.show(nil)
        }
        let showEditor: (NotificationCenter.Publisher.Output) -> Void = {
            note in
            guard let album = note.object as? Album else { return }
            albumEditorPresenter.show(album)
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
                NotificationCenter.default.publisher(for: .editAlbum),
                perform: edit
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .createAlbum),
                perform: create
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteAlbum),
                perform: delete
            )
            .onReceive(
                NotificationCenter.default.publisher(for: .deleteAlbums),
                perform: deleteMany
            )
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
