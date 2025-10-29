import SwiftUI

extension Notification.Name {
    static let requestImportPhotos = Notification.Name("requestImportPhotos")
    static let requestTagPhotos = Notification.Name("requestTagPhotos")

    static let importPhotos = Notification.Name("importPhotos")
    static let tagSelectedPhotos = Notification.Name("tagSelectedPhotos")
}

enum AppIntents {
    static func requestImportPhotos() {
        NotificationCenter.default.post(name: .requestImportPhotos, object: nil)
    }
    static func requestTagPhotos(_ photos: [Photo]) {
        NotificationCenter.default.post(name: .requestTagPhotos, object: photos)
    }

    static func importPhotos(_ folder: URL) {
        NotificationCenter.default.post(name: .importPhotos, object: folder)
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
