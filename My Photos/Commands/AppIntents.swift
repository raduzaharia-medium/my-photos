import SwiftUI

extension Notification.Name {
    static let requestCreateTag = Notification.Name("requestCreateTag")
    static let requestEditTag = Notification.Name("requestEditTag")
    static let requestDeleteTag = Notification.Name("requestDeleteTag")
    static let requestDeleteTags = Notification.Name("requestDeleteTags")
    static let requestImportPhotos = Notification.Name("requestImportPhotos")
}

enum AppIntents {
    static func requestCreateTag() {
        NotificationCenter.default.post(name: .requestCreateTag, object: nil)
    }
    static func requestEditTag(_ tag: Tag) {
        NotificationCenter.default.post(name: .requestEditTag, object: tag)
    }
    static func requestDeleteTag(_ tag: Tag) {
        NotificationCenter.default.post(name: .requestDeleteTag, object: tag)
    }
    static func requestDeleteTags(_ tags: [Tag]) {
        NotificationCenter.default.post(name: .requestDeleteTags, object: tags)
    }
    static func requestImportPhotos() {
        NotificationCenter.default.post(name: .requestImportPhotos, object: nil)
    }
}
