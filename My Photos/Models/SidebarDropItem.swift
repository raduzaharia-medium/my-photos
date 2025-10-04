import SwiftUI
import UniformTypeIdentifiers
import Foundation

enum SidebarDropItem: Transferable {
    case tag(TagDragItem)
    case photo(PhotoDragItem)

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .tagDragItem) { data in
            let item = try JSONDecoder().decode(TagDragItem.self, from: data)
            return .tag(item)
        }

        DataRepresentation(importedContentType: .photoDragItem) { data in
            let item = try JSONDecoder().decode(PhotoDragItem.self, from: data)
            return .photo(item)
        }
    }
}
