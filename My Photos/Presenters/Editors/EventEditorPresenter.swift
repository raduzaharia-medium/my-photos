import SwiftUI

final class EventEditorPresenter: ObservableObject {
    let modalPresenter: ModalService

    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter
    }

    @MainActor
    func show(_ event: Event?) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                EventEditorSheet(
                    event,
                    onSave: { original, name in
                        withAnimation {
                            if let original {
                                EventIntents.edit(original, name: name)
                            } else {
                                EventIntents.create(name: name)
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
