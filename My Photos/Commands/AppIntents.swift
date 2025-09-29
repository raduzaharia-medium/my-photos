import SwiftUI

extension Notification.Name {
    static let requestCreateTag = Notification.Name("requestCreateTag")
    static let requestEditTag = Notification.Name("requestEditTag")
    static let requestDeleteTag = Notification.Name("requestDeleteTag")
    static let requestDeleteTags = Notification.Name("requestDeleteTags")
    static let requestImportPhotos = Notification.Name("requestImportPhotos")
    static let requestTagPhotos = Notification.Name("requestTagPhotos")

    static let createTag = Notification.Name("createTag")
    static let loadTags = Notification.Name("loadTags")
    static let editTag = Notification.Name("editTag")
    static let deleteTag = Notification.Name("deleteTag")
    static let deleteTags = Notification.Name("deleteTags")

    static let resetPhotoFilter = Notification.Name("resetPhotoFilter")
    static let updatePhotoFilter = Notification.Name("updatePhotoFilter")

    static let togglePresentationMode = Notification.Name(
        "togglePresentationMode"
    )
    static let toggleSelectionMode = Notification.Name("toggleSelectionMode")
    static let toggleSelectionFilter = Notification.Name(
        "toggleSelectionFilter"
    )

    static let loadPhotos = Notification.Name("loadPhotos")
    static let importPhotos = Notification.Name("importPhotos")
    static let resetPhotoNavigation = Notification.Name("resetPhotoNavigation")
    static let navigateToPhoto = Notification.Name("navigateToPhoto")
    static let navigateToPreviousPhoto = Notification.Name(
        "navigateToPreviousPhoto"
    )
    static let navigateToNextPhoto = Notification.Name("navigateToNextPhoto")

    static let selectPhoto = Notification.Name("selectPhoto")
    static let deselectPhoto = Notification.Name("deselectPhoto")
    static let togglePhotoSelection = Notification.Name("togglePhotoSelection")
    static let toggleSelectAllPhotos = Notification.Name(
        "toggleSelectAllPhotos"
    )
    static let tagSelectedPhotos = Notification.Name("tagSelectedPhotos")
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
    static func requestTagPhotos() {
        NotificationCenter.default.post(name: .requestTagPhotos, object: nil)
    }

    static func loadTags() {
        NotificationCenter.default.post(name: .loadTags, object: nil)
    }
    static func createTag(name: String, kind: TagKind) {
        NotificationCenter.default.post(
            name: .createTag,
            object: nil,
            userInfo: ["name": name, "kind": kind]
        )
    }
    static func editTag(_ tag: Tag, name: String, kind: TagKind, parent: Tag? = nil) {
        var userInfo: [String: Any] = ["name": name, "kind": kind]
        if let parent { userInfo["parent"] = parent }
        
        NotificationCenter.default.post(
            name: .editTag,
            object: tag,
            userInfo: userInfo
        )
    }
    static func deleteTag(_ tag: Tag) {
        NotificationCenter.default.post(name: .deleteTag, object: tag)
    }
    static func deleteTags(_ tags: [Tag]) {
        NotificationCenter.default.post(name: .deleteTags, object: tags)
    }

    static func resetPhotoFilter() {
        NotificationCenter.default.post(name: .resetPhotoFilter, object: nil)
    }
    static func updatePhotoFilter(_ photoFilters: Set<SidebarItem>) {
        NotificationCenter.default.post(
            name: .updatePhotoFilter,
            object: photoFilters
        )
    }

    static func togglePresentationMode() {
        NotificationCenter.default.post(
            name: .togglePresentationMode,
            object: nil
        )
    }
    static func toggleSelectionMode() {
        NotificationCenter.default.post(name: .toggleSelectionMode, object: nil)
    }
    static func toggleSelectionFilter() {
        NotificationCenter.default.post(
            name: .toggleSelectionFilter,
            object: nil
        )
    }

    static func loadPhotos() {
        NotificationCenter.default.post(name: .loadPhotos, object: nil)
    }
    static func importPhotos(_ folder: URL) {
        NotificationCenter.default.post(name: .importPhotos, object: folder)
    }
    static func resetPhotoNavigation() {
        NotificationCenter.default.post(
            name: .resetPhotoNavigation,
            object: nil
        )
    }
    static func navigateToPhoto(_ photo: Photo) {
        NotificationCenter.default.post(name: .navigateToPhoto, object: photo)
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

    static func selectPhoto(_ photo: Photo) {
        NotificationCenter.default.post(name: .selectPhoto, object: photo)
    }
    static func deselectPhoto(_ photo: Photo) {
        NotificationCenter.default.post(name: .deselectPhoto, object: photo)
    }
    static func togglePhotoSelection(_ photo: Photo) {
        NotificationCenter.default.post(
            name: .togglePhotoSelection,
            object: photo
        )
    }
    static func toggleSelectAllPhotos() {
        NotificationCenter.default.post(
            name: .toggleSelectAllPhotos,
            object: nil
        )
    }
    static func tagSelectedPhotos(_ tag: Tag) {
        NotificationCenter.default.post(name: .tagSelectedPhotos, object: tag)
    }
}
