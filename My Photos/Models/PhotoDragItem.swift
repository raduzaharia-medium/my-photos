import SwiftUI
import UniformTypeIdentifiers

struct PhotoDragItem: Transferable, Codable, Hashable {
    let id: UUID

    init(_ id: UUID) {
        self.id = id
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .photoDragItem)
    }
}

extension UTType {
    static let photoDragItem = UTType(exportedAs: "studio.zar.my-photos.photo-drag-item")
}
