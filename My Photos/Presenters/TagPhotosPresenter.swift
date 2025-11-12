import SwiftUI

@MainActor
final class TagPhotosPresenter: ObservableObject {
    let modalPresenter: ModalService
    let notifier: NotificationService

    init(modalPresenter: ModalService, notifier: NotificationService) {
        self.modalPresenter = modalPresenter
        self.notifier = notifier
    }

    func show(_ photoIDs: [UUID], tags: [SidebarItem]) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                TagPhotosSheet(photoIDs: photoIDs, tags: tags)
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
