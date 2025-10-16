import SwiftUI

final class PersonEditorPresenter: ObservableObject {
    let modalPresenter: ModalService

    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter
    }

    @MainActor
    func show(_ person: Person?) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                PersonEditorSheet(
                    person,
                    onSave: { original, name in
                        withAnimation {
                            if let original {
                                PersonIntents.edit(original, name: name)
                            } else {
                                PersonIntents.create(name: name)
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
