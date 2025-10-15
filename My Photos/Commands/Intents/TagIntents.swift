import SwiftUI

extension Notification.Name {
    static let requestCreateTag = Notification.Name("requestCreateTag")
    static let requestEditTag = Notification.Name("requestEditTag")
    static let requestDeleteTag = Notification.Name("requestDeleteTag")
    static let requestDeleteTags = Notification.Name("requestDeleteTags")

    static let createTag = Notification.Name("createTag")
    static let editTag = Notification.Name("editTag")
    static let deleteTag = Notification.Name("deleteTag")
    static let deleteTags = Notification.Name("deleteTags")
}

enum TagIntents {
    static func requestCreate() {
        NotificationCenter.default.post(name: .requestCreateTag, object: nil)
    }
    static func requestEdit(_ tag: Tag) {
        NotificationCenter.default.post(name: .requestEditTag, object: tag)
    }
    static func requestDelete(_ tag: Tag) {
        NotificationCenter.default.post(name: .requestDeleteTag, object: tag)
    }
    static func requestDelete(_ tags: [Tag]) {
        NotificationCenter.default.post(name: .requestDeleteTags, object: tags)
    }

    static func create(name: String) {
        NotificationCenter.default.post(name: .createTag, object: name)
    }
    static func edit(_ tag: Tag, name: String, parent: Tag? = nil) {
        NotificationCenter.default.post(
            name: .editTag,
            object: tag,
            userInfo: ["name": name]
        )
    }
    static func delete(_ tag: Tag) {
        NotificationCenter.default.post(name: .deleteTag, object: tag)
    }
    static func delete(_ tags: [Tag]) {
        NotificationCenter.default.post(name: .deleteTags, object: tags)
    }
}
