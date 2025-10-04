import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct PhotoDragItem: Transferable, Codable, Hashable {
    let id: UUID

    init(_ id: UUID) {
        self.id = id
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
