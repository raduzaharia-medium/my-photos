import SwiftUI

final class AlbumEditorPresenter: ObservableObject {
    let modalPresenter: ModalService

    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter
    }

    @MainActor
    func show(_ album: Album?) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                AlbumEditorSheet(
                    album,
                    onSave: { original, name in
                        withAnimation {
                            if let original {
                                AlbumIntents.edit(original, name: name)
                            } else {
                                AlbumIntents.create(name: name)
                            }

                            self.modalPresenter.dismiss()
                        }
                    },
                    onCancel: { self.modalPresenter.dismiss() }
                )
            }
        }
    }
}
