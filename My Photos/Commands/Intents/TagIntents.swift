import SwiftUI

extension Notification.Name {
    static let requestCreateTag = Notification.Name("requestCreateTag")
    static let requestEditTag = Notification.Name("requestEditTag")
    static let requestDeleteTag = Notification.Name("requestDeleteTag")
    static let requestDeleteTags = Notification.Name("requestDeleteTags")

    static let createTag = Notification.Name("createTag")
    static let editTag = Notification.Name("editTag")
    static let editTagByID = Notification.Name("editTagByID")
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

    static func create(name: String, parent: Tag? = nil) {
        var userInfo: [AnyHashable: Any] = [:]
        if let parent = parent { userInfo["parent"] = parent }

        NotificationCenter.default.post(
            name: .createTag,
            object: name,
            userInfo: userInfo
        )
    }
    static func edit(_ tag: Tag, name: String, parent: Tag? = nil) {
        var userInfo: [AnyHashable: Any] = ["name": name]
        if let parent = parent { userInfo["parent"] = parent }

        NotificationCenter.default.post(
            name: .editTag,
            object: tag,
            userInfo: userInfo
        )
    }
    static func edit(_ tagID: UUID, name: String? = nil, parent: Tag? = nil) {
        var userInfo: [AnyHashable: Any] = [:]
        if let name = name { userInfo["name"] = name }
        if let parent = parent { userInfo["parent"] = parent }

        NotificationCenter.default.post(
            name: .editTagByID,
            object: tagID,
            userInfo: userInfo
        )
    }
    static func delete(_ tag: Tag) {
        NotificationCenter.default.post(name: .deleteTag, object: tag)
    }
    static func delete(_ tags: [Tag]) {
        NotificationCenter.default.post(name: .deleteTags, object: tags)
    }
}
