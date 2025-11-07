import SwiftUI

@MainActor
final class ImportPhotosPresenter: ObservableObject {
    let modalPresenter: ModalService
    let notifier: NotificationService

    init(modalPresenter: ModalService, notifier: NotificationService) {
        self.modalPresenter = modalPresenter
        self.notifier = notifier
    }

    @MainActor
    func show(_ folder: URL) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                ImportPhotosSheet(folder)
//                { result in
//                    switch result {
//                    case .success: return
//                    case .failure(let error):
//                        notifier.show(
//                            "Failed to import: \(error.localizedDescription)",
//                            .error
//                        )
//
//                    }
//                }
            }
        }
    }
}
