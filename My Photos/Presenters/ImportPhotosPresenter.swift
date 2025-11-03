import SwiftUI

@MainActor
final class ImportPhotosPresenter: ObservableObject {
    let modalPresenter: ModalService

    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter
    }

    @MainActor
    func show(_ parsed: [ParsedPhoto], _ photoImporter: PhotoImportService) {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                ImportPhotosSheet(parsed, photoImporter)
            }
        }
    }
}
