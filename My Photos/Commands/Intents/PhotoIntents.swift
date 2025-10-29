import SwiftUI

extension Notification.Name {
    static let toggleSelectionMode = Notification.Name("toggleSelectionMode")
    static let enablePhotoSelectionMode = Notification.Name(
        "enablePhotoSelectionMode"
    )
    static let disablePhotoSelectionMode = Notification.Name(
        "disablePhotoSelectionMode"
    )

    static let selectPhotos = Notification.Name("selectPhotos")
    static let toggleSelection = Notification.Name("toggleSelection")
}

enum PhotoIntents {
    static func toggleSelectionMode() {
        NotificationCenter.default.post(name: .toggleSelectionMode, object: nil)
    }
    static func enablePhotoSelectionMode() {
        NotificationCenter.default.post(
            name: .enablePhotoSelectionMode,
            object: nil
        )
    }
    static func disablePhotoSelectionMode() {
        NotificationCenter.default.post(
            name: .disablePhotoSelectionMode,
            object: nil
        )
    }

    static func selectPhotos(_ photos: [Photo]) {
        NotificationCenter.default.post(name: .selectPhotos, object: photos)
    }
    static func toggleSelection(_ photo: Photo) {
        NotificationCenter.default.post(name: .toggleSelection, object: photo)
    }
}
