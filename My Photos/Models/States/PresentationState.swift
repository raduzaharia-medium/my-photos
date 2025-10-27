import Observation
import SwiftUI

@MainActor
@Observable
final class PresentationState {
    var photoSource: Filter = .all
    var photoFilter: Set<SidebarItem> = []
    var photoSelection: Set<Photo> = []
    
    func isSelected(_ photo: Photo) -> Bool {
        return photoSelection.contains(photo)
    }
}
