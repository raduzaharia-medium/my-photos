import SwiftUI

final class DeleteAlbumPresenter: ObservableObject {
    let confirmer: ConfirmationService

    init(confirmer: ConfirmationService) {
        self.confirmer = confirmer
    }

    @MainActor
    func show(_ album: Album) {
        withAnimation {
            confirmer.show(
                "Delete \(album.name)?",
                "Are you sure you want to delete this album?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        AlbumIntents.delete(album)
                    }
                }
            )
        }

    }

    @MainActor
    func show(_ albums: [Album]) {
        withAnimation {
            confirmer.show(
                "Delete \(albums.count) Albums?",
                "Are you sure you want to delete these albums?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        AlbumIntents.delete(albums)
                    }
                }
            )
        }
    }
}
