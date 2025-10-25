import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum SidebarDropItem: Transferable {
    case tag(SidebarDragItem)
    case photo(PhotoDragItem)

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .sidebarDragItem) { data in
            let item = try JSONDecoder().decode(SidebarDragItem.self, from: data)
            return .tag(item)
        }

        DataRepresentation(importedContentType: .photoDragItem) { data in
            let item = try JSONDecoder().decode(PhotoDragItem.self, from: data)
            return .photo(item)
        }
    }
}

extension Collection where Element == SidebarDropItem {
    var tags: [SidebarDragItem] {
        compactMap {
            if case .tag(let tag) = $0 { tag } else { nil }
        }
    }

    var photos: [PhotoDragItem] {
        compactMap {
            if case .photo(let photo) = $0 { photo } else { nil }
        }
    }
}
