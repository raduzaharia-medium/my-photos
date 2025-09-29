import SwiftUI
import UniformTypeIdentifiers

struct TagDragItem: Codable, Transferable, Hashable {
    let id: UUID

    init(_ id: UUID) {
        self.id = id
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
