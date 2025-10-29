import SwiftUI

extension Notification.Name {
    static let importPhotos = Notification.Name("importPhotos")
    static let tagSelectedPhotos = Notification.Name("tagSelectedPhotos")
}

enum AppIntents {
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
