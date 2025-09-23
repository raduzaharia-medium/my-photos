import Observation
import SwiftUI

enum PresentationMode: String, CaseIterable, Identifiable {
    case grid = "Grid"
    case map = "Map"

    var id: String { rawValue }
}

@MainActor
@Observable
final class PresentationState {
    var photoFilter: Set<SidebarItem> = []
    var selectedPhotos: Set<Photo> = []
    var presentationMode: PresentationMode = .grid
    var showOnlySelected: Bool = false
    var isSelecting: Bool = false

    var selectedTags: [Tag] { photoFilter.selectedTags }
    var selectedFilters: [Filter] { photoFilter.selectedFilters }

    var canEditOrDeleteSelection: Bool { photoFilter.canEditOrDeleteSelection }
    var canEditSelection: Bool { photoFilter.canEditSelection }
    var canDeleteSelection: Bool { photoFilter.canDeleteSelection }
    var canDeleteManySelection: Bool { photoFilter.canDeleteManySelection }
    
    func isPhotoSelected(_ photo: Photo) -> Bool {
        return selectedPhotos.contains(photo)
    }
}
