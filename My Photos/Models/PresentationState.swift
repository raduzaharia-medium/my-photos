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
    var currentPhoto: Photo? = nil

    var selectedTags: [Tag] { photoFilter.selectedTags }
    var selectedFilters: [Filter] { photoFilter.selectedFilters }

    var canEditOrDeleteSelection: Bool { photoFilter.canEditOrDeleteSelection }
    var canEditSelection: Bool { photoFilter.canEditSelection }
    var canDeleteSelection: Bool { photoFilter.canDeleteSelection }
    var canDeleteManySelection: Bool { photoFilter.canDeleteManySelection }

    func isPhotoSelected(_ photo: Photo) -> Bool {
        return selectedPhotos.contains(photo)
    }
    func getFilteredPhotos(_ photos: [Photo]) -> [Photo] {
        let result = photos.filtered(by: photoFilter)
        guard isSelecting else { return result }
        guard showOnlySelected else { return result }

        return result.filter { selectedPhotos.contains($0) }

    }
    func getCurrentPhotoIndex(_ photos: [Photo]) -> Int? {
        guard let currentPhoto else { return nil }

        let photos = getFilteredPhotos(photos)
        return photos.firstIndex(of: currentPhoto)
    }
    func selectNextPhoto(_ photos: [Photo]) {
        guard let current = currentPhoto else { return }

        let filteredPhotos = getFilteredPhotos(photos)

        guard let currentIndex = filteredPhotos.firstIndex(of: current) else { return }
        guard currentIndex + 1 < filteredPhotos.count else { return }

        currentPhoto = filteredPhotos[currentIndex + 1]
    }
    func selectPreviousPhoto(_ photos: [Photo]) {
        guard let current = currentPhoto else { return }
        
        let filteredPhotos = getFilteredPhotos(photos)
        
        guard let currentIndex = filteredPhotos.firstIndex(of: current) else { return }
        guard currentIndex > 0 else { return }
        
        currentPhoto = filteredPhotos[currentIndex - 1]
    }
}
