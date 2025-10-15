import SwiftUI

final class DeleteAlbumPresenter: ObservableObject {
    let alerter: AlertService

    init(alerter: AlertService) {
        self.alerter = alerter
    }

    @MainActor
    func show(_ album: Album) {
        withAnimation {
            alerter.show(
                "Delete \(album.name)?",
                "Are you sure you want to delete this album?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        AlbumIntents.delete(album)
                        AppIntents.resetPhotoFilter()
                    }
                }
            )
        }

    }

    @MainActor
    func show(_ albums: [Album]) {
        withAnimation {
            alerter.show(
                "Delete \(albums.count) Albums?",
                "Are you sure you want to delete these albums?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        AlbumIntents.delete(albums)
                        AppIntents.resetPhotoFilter()
                    }
                }
            )
        }
    }
}
