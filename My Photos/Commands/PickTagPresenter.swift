import SwiftUI

final class PickTagPresenter: ObservableObject {
    let modalPresenter: ModalService
    let notifier: NotificationService
    let tagStore: TagStore

    init(
        modalPresenter: ModalService,
        notifier: NotificationService,
        tagStore: TagStore
    ) {
        self.modalPresenter = modalPresenter
        self.notifier = notifier
        self.tagStore = tagStore
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
