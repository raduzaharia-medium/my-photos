import SwiftUI

@MainActor
final class PickLocationPresenter: ObservableObject {
    let modalPresenter: ModalService
    
    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter
    }

    func show(_ photos: [Photo]) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                LocationPickerSheet(
                    photos: photos,
                    onSave: { photos, location in
                        let photoIDs = photos.map(\.id)
                        
                        // TODO: PhotoIntents.setLocation(photoIDs, location)
                        PhotoIntents.toggleSelectionMode()

                        self.modalPresenter.dismiss()
                    },
                    onCancel: { self.modalPresenter.dismiss() }
                )
            }
        }
    }
}
