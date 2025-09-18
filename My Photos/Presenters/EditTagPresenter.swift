import SwiftUI

extension View {
    func presentTagEditor(_ tag: Tag?, modalPresenter: ModalService, notifier: NotificationService, tagActions: TagActions) {
        My_Photos.presentTagEditor(tag, modalPresenter: modalPresenter, notifier: notifier, tagActions: tagActions)
    }
}

@MainActor
func presentTagEditor(_ tag: Tag?, modalPresenter: ModalService, notifier: NotificationService, tagActions: TagActions) {
    withAnimation {
        modalPresenter.show(onDismiss: {}) {
            TagEditorSheet(
                tag,
                onSave: { original, name, kind in
                    withAnimation {
                        do {
                            try tagActions.upsert(original?.id, name: name, kind: kind)
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
