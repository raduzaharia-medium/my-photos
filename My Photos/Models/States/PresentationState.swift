import Observation
import SwiftUI

@MainActor
@Observable
final class PresentationState {
    var tags: [Tag] = []

    var photoSource: Filter = .all
    var photoFilter: Set<SidebarItem> = []
    
    var selectedPhotos: Set<Photo> = []
    var showOnlySelected: Bool = false
    var isSelecting: Bool = false
    var allPhotosSelected: Bool = false

    func getTag(_ id: UUID) -> Tag? {
        return tags.first(where: { $0.id == id })
    }

    func getTags(searchText: String) -> [Tag] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        return tags.filter {
            $0.name.range(
                of: trimmed,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) != nil
        }
    }

    func isSelected(_ photo: Photo) -> Bool {
        return selectedPhotos.contains(photo)
    }
}
