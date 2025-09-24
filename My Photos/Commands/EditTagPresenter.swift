import SwiftUI

final class EditTagPresenter: ObservableObject {
    let modalPresenter: ModalService
    let tagStore: TagStore

    init(
        modalPresenter: ModalService,
        tagStore: TagStore
    ) {
        self.modalPresenter = modalPresenter
        self.tagStore = tagStore
    }

    @MainActor
    func show(_ tag: Tag?) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                TagEditorSheet(
                    tag,
                    onSave: { original, name, kind in
                        withAnimation {
                            AppIntents.editTag(
                                original!,
                                name: name,
                                kind: kind
                            )
                            
                            self.modalPresenter.dismiss()
                        }
                    },
                    onCancel: { self.modalPresenter.dismiss() }
                )
            }
        }
    }
}
