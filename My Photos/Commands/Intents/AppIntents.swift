import SwiftUI

extension Notification.Name {
    static let requestImportPhotos = Notification.Name("requestImportPhotos")
    static let requestTagPhotos = Notification.Name("requestTagPhotos")

    static let toggleSelectionMode = Notification.Name("toggleSelectionMode")
    static let toggleSelectionFilter = Notification.Name(
        "toggleSelectionFilter"
    )

    static let importPhotos = Notification.Name("importPhotos")
    static let navigateToPreviousPhoto = Notification.Name(
        "navigateToPreviousPhoto"
    )
    static let navigateToNextPhoto = Notification.Name("navigateToNextPhoto")

    static let selectNextTagSuggestion = Notification.Name(
        "selectNextTagSuggestion"
    )
    static let selectPreviousTagSuggestion = Notification.Name(
        "selectPreviousTagSuggestion"
    )
    static let addSelectedTagToEditor = Notification.Name(
        "addSelectedTagToEditor"
    )
    static let addTagToEditor = Notification.Name("addTagToEditor")
    static let removeTagFromEditor = Notification.Name("removeTagFromEditor")

    static let selectPhoto = Notification.Name("selectPhoto")
    static let deselectPhoto = Notification.Name("deselectPhoto")
    static let togglePhotoSelection = Notification.Name("togglePhotoSelection")
    static let toggleSelectAllPhotos = Notification.Name(
        "toggleSelectAllPhotos"
    )
    static let tagSelectedPhotos = Notification.Name("tagSelectedPhotos")
}

enum AppIntents {
    static func requestImportPhotos() {
        NotificationCenter.default.post(name: .requestImportPhotos, object: nil)
    }
    static func requestTagPhotos(_ photos: [Photo]) {
        NotificationCenter.default.post(name: .requestTagPhotos, object: photos)
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

    static func importPhotos(_ folder: URL) {
        NotificationCenter.default.post(name: .importPhotos, object: folder)
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

    static func selectNextTagSuggestion() {
        NotificationCenter.default.post(
            name: .selectNextTagSuggestion,
            object: nil
        )
    }
    static func selectPreviousTagSuggestion() {
        NotificationCenter.default.post(
            name: .selectPreviousTagSuggestion,
            object: nil
        )
    }
    static func addSelectedTagToEditor() {
        NotificationCenter.default.post(
            name: .addSelectedTagToEditor,
            object: nil
        )
    }
    static func addTagToEditor(_ tag: Tag) {
        NotificationCenter.default.post(name: .addTagToEditor, object: tag)
    }
    static func removeTagFromEditor(_ tag: Tag) {
        NotificationCenter.default.post(name: .removeTagFromEditor, object: tag)
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
    static func tagSelectedPhotos(_ photos: Set<Photo>, _ tags: Set<SidebarItem>) {
        NotificationCenter.default.post(name: .tagSelectedPhotos, object: tags)
    }
}
