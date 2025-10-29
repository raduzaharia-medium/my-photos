import SwiftUI

@MainActor
final class PickTagPresenter: ObservableObject {
    let modalPresenter: ModalService
    
    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter
    }

    @MainActor
    func show(_ photos: [Photo]) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                TagPickerSheet(
                    photos: photos,
                    onSave: { photos, tags in
                        AppIntents.tagSelectedPhotos(photos, tags)
                        PhotoIntents.toggleSelectionMode()

                        self.modalPresenter.dismiss()
                    },
                    onCancel: { self.modalPresenter.dismiss() }
                )
            }
        }
    }
}
