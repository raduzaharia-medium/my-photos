import Observation
import SwiftUI

@MainActor
@Observable
final class PresentationState {
    var photoSource: Filter = .all
    var photoFilter: Set<SidebarItem> = []
    var photoSelection: Set<Photo> = []
    
    var showOnlySelected: Bool = false
    var isSelecting: Bool = false
    var allPhotosSelected: Bool = false

    func isSelected(_ photo: Photo) -> Bool {
        return photoSelection.contains(photo)
    }
}
