import SwiftUI

extension Notification.Name {
    static let requestImportPhotos = Notification.Name("requestImportPhotos")
    static let requestTagPhotos = Notification.Name("requestTagPhotos")

    static let toggleSelectionMode = Notification.Name("toggleSelectionMode")

    static let importPhotos = Notification.Name("importPhotos")
    static let selectPhotos = Notification.Name("selectPhotos")
    static let enablePhotoSelectionMode = Notification.Name("enablePhotoSelectionMode")
    static let disablePhotoSelectionMode = Notification.Name("disablePhotoSelectionMode")
    static let toggleSelection = Notification.Name("toggleSelection")
    static let tagSelectedPhotos = Notification.Name("tagSelectedPhotos")
}

enum AppIntents {
    static func requestImportPhotos() {
        NotificationCenter.default.post(name: .requestImportPhotos, object: nil)
    }
    static func requestTagPhotos(_ photos: [Photo]) {
        NotificationCenter.default.post(name: .requestTagPhotos, object: photos)
    }

    static func toggleSelectionMode() {
        NotificationCenter.default.post(name: .toggleSelectionMode, object: nil)
    }

    static func importPhotos(_ folder: URL) {
        NotificationCenter.default.post(name: .importPhotos, object: folder)
    }
    static func selectPhotos(_ photos: [Photo]) {
        NotificationCenter.default.post(name: .selectPhotos, object: photos)
    }
    static func enablePhotoSelectionMode() {
        NotificationCenter.default.post(name: .enablePhotoSelectionMode, object: nil)
    }
    static func disablePhotoSelectionMode() {
        NotificationCenter.default.post(name: .disablePhotoSelectionMode, object: nil)
    }
    static func toggleSelection(_ photo: Photo) {
        NotificationCenter.default.post(name: .toggleSelection, object: photo)
    }
    static func tagSelectedPhotos(
        _ photos: [Photo],
        _ tags: [SidebarItem]
    ) {
        NotificationCenter.default.post(
            name: .tagSelectedPhotos,
            object: photos,
            userInfo: ["tags": tags]
        )
    }
}
