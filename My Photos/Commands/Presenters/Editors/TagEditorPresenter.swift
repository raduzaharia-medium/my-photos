import SwiftUI

final class TagEditorPresenter: ObservableObject {
    let modalPresenter: ModalService

    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter
    }

    @MainActor
    func show(_ tag: Tag?) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                TagEditorSheet(
                    tag,
                    onSave: { original, name in
                        withAnimation {
                            if let original {
                                AppIntents.editTag(original, name: name)
                            } else {
                                AppIntents.createTag(name: name)
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
