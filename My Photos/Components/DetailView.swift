import SwiftData
import SwiftUI

struct DetailView: View {
    @Environment(PresentationState.self) private var presentationState
    @Query private var allPhotos: [Photo]

    private var filters: Set<SidebarItem> { presentationState.photoFilter }
    private var photos: [Photo] {
        var set = Set<Photo>()

        if filters.selectedFilters.count == filters.count {
            set = Set(allPhotos)
        } else {
            for filter in filters { set.formUnion(filter.photos) }
        }

        if presentationState.showOnlySelected {
            set = set.filter {
                photo in presentationState.isPhotoSelected(photo)
            }
        }

        return Array(set).sorted {
            $0.dateTaken ?? .distantFuture > $1.dateTaken ?? .distantFuture
        }
    }

    var body: some View {
        TabView {
            Tab("Grid", systemImage: "rectangle.grid.2x2") {
                PhotosGrid(photos: photos)
            }
            Tab("Map", systemImage: "map") { PhotosMap(photos: photos) }
        }.toolbar {
            DetailViewToolbar()
        }
        .navigationTitle(
            (presentationState.selectedTags.count > 1)
                ? "Multiple Collections"
                : (presentationState.selectedTags.first?.name ?? "All Photos")
        )
    }
}
