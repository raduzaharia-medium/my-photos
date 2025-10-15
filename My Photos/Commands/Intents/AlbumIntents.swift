import SwiftUI

extension Notification.Name {
    static let requestCreateAlbum = Notification.Name("requestCreateAlbum")
    static let requestEditAlbum = Notification.Name("requestEditAlbum")
    static let requestDeleteAlbum = Notification.Name("requestDeleteAlbum")
    static let requestDeleteAlbums = Notification.Name("requestDeleteAlbums")

    static let createAlbum = Notification.Name("createAlbum")
    static let editAlbum = Notification.Name("editAlbum")
    static let deleteAlbum = Notification.Name("deleteAlbum")
    static let deleteAlbums = Notification.Name("deleteAlbums")
}

enum AlbumIntents {
    static func requestCreate() {
        NotificationCenter.default.post(name: .requestCreateAlbum, object: nil)
    }
    static func requestEdit(_ tag: Tag) {
        NotificationCenter.default.post(name: .requestEditAlbum, object: tag)
    }
    static func requestDelete(_ tag: Tag) {
        NotificationCenter.default.post(name: .requestDeleteAlbum, object: tag)
    }
    static func requestDelete(_ tags: [Tag]) {
        NotificationCenter.default.post(
            name: .requestDeleteAlbums,
            object: tags
        )
    }

    static func create(name: String) {
        NotificationCenter.default.post(name: .createAlbum, object: name)
    }
    static func edit(_ album: Album, name: String) {
        NotificationCenter.default.post(
            name: .editTag,
            object: album,
            userInfo: ["name": name]
        )
    }
    static func delete(_ album: Album) {
        NotificationCenter.default.post(name: .deleteAlbum, object: album)
    }
    static func delete(_ albums: [Album]) {
        NotificationCenter.default.post(name: .deleteAlbums, object: albums)
    }
}
