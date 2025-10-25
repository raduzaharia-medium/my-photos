import SwiftUI
import UniformTypeIdentifiers

struct SidebarDragItem: Codable, Transferable, Hashable {
    let id: UUID

    init(_ id: UUID) {
        self.id = id
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .sidebarDragItem)
    }
}

extension UTType {
    static let sidebarDragItem = UTType(
        exportedAs: "studio.zar.my-photos.sidebar-drag-item"
    )
}
