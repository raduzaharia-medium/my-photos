import SwiftUI

extension Notification.Name {
    static let requestCreateTag = Notification.Name("requestCreateTag")
    static let requestEditTag = Notification.Name("requestEditTag")
    static let requestDeleteTag = Notification.Name("requestDeleteTag")
    static let requestDeleteTags = Notification.Name("requestDeleteTags")
    static let requestImportPhotos = Notification.Name("requestImportPhotos")

    static let resetTagSelection = Notification.Name("resetTagSelection")
    static let togglePresentationMode = Notification.Name("togglePresentationMode")
    static let toggleSelectionMode = Notification.Name("toggleSelectionMode")
    static let toggleSelectionFilter = Notification.Name("toggleSelectionFilter")

    static let navigateToPreviousPhoto = Notification.Name(
        "navigateToPreviousPhoto"
    )
    static let navigateToNextPhoto = Notification.Name("navigateToNextPhoto")
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

    static func resetTagSelection() {
        NotificationCenter.default.post(name: .resetTagSelection, object: nil)
    }
    static func togglePresentationMode() {
        NotificationCenter.default.post(name: .togglePresentationMode, object: nil)
    }
    static func toggleSelectionMode() {
        NotificationCenter.default.post(name: .toggleSelectionMode, object: nil)
    }
    static func toggleSelectionFilter() {
        NotificationCenter.default.post(name: .toggleSelectionFilter, object: nil)
    }

    static func navigateToPreviousPhoto() {
        NotificationCenter.default.post(
            name: .navigateToPreviousPhoto,
            object: nil
        )
    }
    static func navigateToNextPhoto() {
        NotificationCenter.default.post(name: .navigateToNextPhoto, object: nil)
    }
}
