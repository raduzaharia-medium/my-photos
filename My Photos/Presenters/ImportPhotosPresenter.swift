import SwiftUI

extension View {
    func presentImportPhotos(fileImporter: FileImportService, notifier: NotificationService) {
        My_Photos.presentImportPhotos(fileImporter: fileImporter, notifier: notifier)
    }
}

@MainActor
func presentImportPhotos(fileImporter: FileImportService, notifier: NotificationService) {
    withAnimation {
        fileImporter.pickSingleFolder { result in
            switch result {
            case .success(let urls):
                guard let folder = urls.first else { return }
                notifier.show(
                    "Imported \(folder.lastPathComponent)",
                    .success
                )

            case .failure(let error):
                notifier.show(
                    "Failed to import: \(error.localizedDescription)",
                    .error
                )
            }
        }
    }
}
