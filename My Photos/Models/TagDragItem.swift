import SwiftUI
import UniformTypeIdentifiers

struct TagDragItem: Codable, Transferable, Hashable {
    let name: String
    let kind: TagKind

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
