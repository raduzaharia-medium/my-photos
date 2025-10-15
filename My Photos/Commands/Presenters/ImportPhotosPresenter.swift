import SwiftUI

final class ImportPhotosPresenter: ObservableObject {
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
                    AppIntents.importPhotos(folder)
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
