import SwiftUI

final class EditTagPresenter: ObservableObject {
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
                            
                            self.notifier.show("Tag saved", .success)
                            self.modalPresenter.dismiss()
                        }
                    },
                    onCancel: { self.modalPresenter.dismiss() }
                )
            }
        }
    }
}
