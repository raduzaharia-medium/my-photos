import SwiftUI

extension Notification.Name {
    static let requestImportPhotos = Notification.Name("requestImportPhotos")
    static let requestTagPhotos = Notification.Name("requestTagPhotos")
    static let requestChangeDatePhotos = Notification.Name(
        "requestChangeDatePhotos"
    )
    static let requestChangeLocationPhotos = Notification.Name(
        "requestChangeLocationPhotos"
    )
    static let requestChangeAlbumPhotos = Notification.Name(
        "requestChangeAlbumPhotos"
    )

    static let importPhotos = Notification.Name("importPhotos")
    static let tagPhotos = Notification.Name("tagPhotos")
    static let photoImported = Notification.Name("photoImported")

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
    static func requestChangeDate(
        year: Int? = nil,
        month: Int? = nil,
        day: Int? = nil
    ) {
        var userInfo: [String: Int] = [:]

        if let year { userInfo["year"] = year }
        if let month { userInfo["month"] = month }
        if let day { userInfo["day"] = day }

        NotificationCenter.default.post(
            name: .requestChangeDatePhotos,
            object: nil,
            userInfo: userInfo
        )
    }
    static func requestChangeLocation(_ photos: [Photo]) {
        NotificationCenter.default.post(
            name: .requestChangeDatePhotos,
            object: photos
        )
    }
    static func requestChangeAlbum(album: Album? = nil) {
        NotificationCenter.default.post(
            name: .requestChangeAlbumPhotos,
            object: album,
        )
    }

    static func `import`(_ folder: URL) {
        NotificationCenter.default.post(name: .importPhotos, object: folder)
    }
    static func tag(_ photoIDs: [UUID], _ tags: [SidebarItem]) {
        NotificationCenter.default.post(
            name: .tagPhotos,
            object: photoIDs,
            userInfo: ["tags": tags]
        )
    }
    static func photoImported() {
        NotificationCenter.default.post(name: .photoImported, object: nil)
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
