import SwiftUI

struct EditTagPresenter {
    let modalPresenter: ModalService
    let notifier: NotificationService
    let tagStore: TagStore

    @MainActor
    func show(_ tag: Tag?) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                TagEditorSheet(
                    tag,
                    onSave: { original, name, kind in
                        withAnimation {
                            do {
                                try tagStore.upsert(original?.id, name: name, kind: kind)
                                notifier.show("Tag saved", .success)
                            } catch {
                                notifier.show("Could not save tag", .error)
                            }
                            modalPresenter.dismiss()
                        }
                    },
                    onCancel: { modalPresenter.dismiss() }
                )
            }
        }
    }
}

extension View {
    func presentTagEditor(_ tag: Tag?, modalPresenter: ModalService, notifier: NotificationService, tagStore: TagStore) {
        My_Photos.presentTagEditor(tag, modalPresenter: modalPresenter, notifier: notifier, tagStore: tagStore)
    }
}

@MainActor
func presentTagEditor(_ tag: Tag?, modalPresenter: ModalService, notifier: NotificationService, tagStore: TagStore) {
    withAnimation {
        modalPresenter.show(onDismiss: {}) {
            TagEditorSheet(
                tag,
                onSave: { original, name, kind in
                    withAnimation {
                        do {
                            try tagStore.upsert(original?.id, name: name, kind: kind)
                            notifier.show("Tag saved", .success)
                        } catch {
                            notifier.show("Could not save tag", .error)
                        }
                        
                        modalPresenter.dismiss()
                    }
                },
                onCancel: { modalPresenter.dismiss() }
            )
        }
    }
}
