import SwiftUI

final class PickFolderPresenter: ObservableObject {
    let fileImporter: FileImportService
    let notifier: NotificationService

    init(fileImporter: FileImportService, notifier: NotificationService) {
        self.fileImporter = fileImporter
        self.notifier = notifier
    }

    @MainActor
    func show() {
        withAnimation {
            fileImporter.pickSingleFolder { result in
                switch result {
                case .success(let urls): self.callImport(urls: urls)
                case .failure(let error): self.abortImport(error: error)
                }
            }
        }
    }

    private func callImport(urls: [URL]) {
        guard let folder = urls.first else { return }
        PhotoIntents.import(folder)
    }

    @MainActor
    private func abortImport(error: Error) {
        notifier.show("Failed to import: \(error.localizedDescription)", .error)
    }
}
