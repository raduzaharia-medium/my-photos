import SwiftUI

final class EditTagPresenter: ObservableObject {
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
                    onSave: { original, name, kind in
                        withAnimation {
                            if let original {
                                AppIntents.editTag(
                                    original,
                                    name: name,
                                    kind: kind
                                )
                            } else {
                                AppIntents.createTag(name: name, kind: kind)
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
