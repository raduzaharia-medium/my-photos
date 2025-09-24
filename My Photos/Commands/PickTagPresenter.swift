import SwiftUI

final class PickTagPresenter: ObservableObject {
    let modalPresenter: ModalService

    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter
    }

    @MainActor
    func show() {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                TagPickerSheet(
                    onSave: { tag in
                        AppIntents.tagSelectedPhotos(tag)
                        AppIntents.toggleSelectionMode()

                        self.modalPresenter.dismiss()
                    },
                    onCancel: { self.modalPresenter.dismiss() }
                )
            }
        }
    }
}
