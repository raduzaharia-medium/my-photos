import SwiftUI

@MainActor
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
                    onSave: { tags in
                        AppIntents.tagSelectedPhotos(tags)
                        AppIntents.toggleSelectionMode()

                        self.modalPresenter.dismiss()
                    },
                    onCancel: { self.modalPresenter.dismiss() }
                )
            }
        }
    }
}
