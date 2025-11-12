import SwiftUI

@MainActor
final class PickDatePresenter: ObservableObject {
    let modalPresenter: ModalService
    
    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter
    }

    func show(_ photos: [Photo]) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                DatePickerSheet(
                    photos: photos,
                    onSave: { photos, date in
                        let photoIDs = photos.map(\.id)
                        
                        // TODO: PhotoIntents.setDateTaken(photoIDs, date)
                        PhotoIntents.toggleSelectionMode()

                        self.modalPresenter.dismiss()
                    },
                    onCancel: { self.modalPresenter.dismiss() }
                )
            }
        }
    }
}
