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
    var photos: [Photo] = []
    var tags: [Tag] = []
    var years: [DateTakenYear] = []
    var countries: [PlaceCountry] = []

    var photoFilter: Set<SidebarItem> = []
    var selectedPhotos: Set<Photo> = []
    var presentationMode: PresentationMode = .grid
    var showOnlySelected: Bool = false
    var isSelecting: Bool = false
    var currentPhoto: Photo? = nil

    var filteredPhotos: [Photo] {
        guard isSelecting else { return photos }
        guard showOnlySelected else { return photos }

        return photos.filter { selectedPhotos.contains($0) }
    }
    var currentPhotoIndex: Int? {
        guard let currentPhoto else { return nil }
        return filteredPhotos.firstIndex(of: currentPhoto)
    }
    var allPhotosSelected: Bool {
        return Set(filteredPhotos).isSubset(of: selectedPhotos)
    }

    var selectedTags: [Tag] { photoFilter.selectedTags }
    var selectedFilters: [Filter] { photoFilter.selectedFilters }

    var canEditOrDeleteSelection: Bool { photoFilter.canEditOrDeleteSelection }
    var canEditSelection: Bool { photoFilter.canEditSelection }
    var canDeleteSelection: Bool { photoFilter.canDeleteSelection }
    var canDeleteManySelection: Bool { photoFilter.canDeleteManySelection }

    func getTag(_ id: UUID) -> Tag? {
        return tags.first(where: { $0.id == id })
    }
    func getPhoto(_ id: UUID) -> Photo? {
        return photos.first(where: { $0.id == id })
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

    func isPhotoSelected(_ photo: Photo) -> Bool {
        return selectedPhotos.contains(photo)
    }

    func goToPreviousPhoto() {
        guard let current = currentPhoto else { return }
        guard let currentIndex = filteredPhotos.firstIndex(of: current) else {
            return
        }
        guard currentIndex > 0 else { return }

        currentPhoto = filteredPhotos[currentIndex - 1]
    }
    func goToNextPhoto() {
        guard let current = currentPhoto else { return }
        guard let currentIndex = filteredPhotos.firstIndex(of: current) else {
            return
        }
        guard currentIndex + 1 < filteredPhotos.count else { return }

        currentPhoto = filteredPhotos[currentIndex + 1]
    }
}
