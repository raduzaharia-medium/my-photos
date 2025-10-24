import SwiftUI
import UniformTypeIdentifiers

struct TagDragItem: Codable, Transferable, Hashable {
    let id: UUID

    init(_ id: UUID) {
        self.id = id
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .tagDragItem)
    }
}

extension UTType {
    static let tagDragItem = UTType(
        exportedAs: "studio.zar.my-photos.tag-drag-item"
    )
}
