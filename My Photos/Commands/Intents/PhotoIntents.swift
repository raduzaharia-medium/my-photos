import SwiftUI

extension Notification.Name {
    static let requestImportPhotos = Notification.Name("requestImportPhotos")
    static let requestTagPhotos = Notification.Name("requestTagPhotos")

    static let importPhotos = Notification.Name("importPhotos")
    static let tagPhotos = Notification.Name("tagPhotos")

    static let togglePhotoSelectionMode = Notification.Name(
        "togglePhotoSelectionMode"
    )
    static let enablePhotoSelectionMode = Notification.Name(
        "enablePhotoSelectionMode"
    )
    static let disablePhotoSelectionMode = Notification.Name(
        "disablePhotoSelectionMode"
    )

    static let clearPhotoSelection = Notification.Name("clearPhotoSelection")
    static let selectPhoto = Notification.Name("selectPhoto")
    static let selectPhotos = Notification.Name("selectPhotos")
    static let togglePhotoSelection = Notification.Name("togglePhotoSelection")
}

enum PhotoIntents {
    static func requestImport() {
        NotificationCenter.default.post(name: .requestImportPhotos, object: nil)
    }
    static func requestTag(_ photos: [Photo]) {
        NotificationCenter.default.post(name: .requestTagPhotos, object: photos)
    }

    static func `import`(_ folder: URL) {
        NotificationCenter.default.post(name: .importPhotos, object: folder)
    }
    static func tag(_ photos: [Photo], _ tags: [SidebarItem]) {
        NotificationCenter.default.post(
            name: .tagPhotos,
            object: photos,
            userInfo: ["tags": tags]
        )
    }

    static func toggleSelectionMode() {
        NotificationCenter.default.post(
            name: .togglePhotoSelectionMode,
            object: nil
        )
    }
    static func enableSelectionMode() {
        NotificationCenter.default.post(
            name: .enablePhotoSelectionMode,
            object: nil
        )
    }
    static func disableSelectionMode() {
        NotificationCenter.default.post(
            name: .disablePhotoSelectionMode,
            object: nil
        )
    }

    static func clearSelection() {
        NotificationCenter.default.post(name: .clearPhotoSelection, object: nil)
    }
    static func select(_ photo: Photo) {
        NotificationCenter.default.post(name: .selectPhoto, object: photo)
    }
    static func select(_ photos: [Photo]) {
        NotificationCenter.default.post(name: .selectPhotos, object: photos)
    }
    static func toggleSelection(_ photo: Photo) {
        NotificationCenter.default.post(
            name: .togglePhotoSelection,
            object: photo
        )
    }
}
