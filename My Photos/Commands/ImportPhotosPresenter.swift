import SwiftUI

class ImportPhotosPresenter: ObservableObject {
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
                case .success(let urls):
                    guard let folder = urls.first else { return }
                    self.notifier.show(
                        "Imported \(folder.lastPathComponent)",
                        .success
                    )

                case .failure(let error):
                    self.notifier.show(
                        "Failed to import: \(error.localizedDescription)",
                        .error
                    )
                }
            }
        }

    }
}
