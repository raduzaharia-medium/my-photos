import SwiftData
import SwiftUI

struct DetailView: View {
    @Environment(PresentationState.self) private var state
    @Query private var allPhotos: [Photo]

    private var filters: Set<SidebarItem> { state.photoFilter }
    private var source: Filter { state.photoSource }
    private var photos: [Photo] {
        var set = Set<Photo>()

        if filters.isEmpty {
            set = Set(allPhotos)
        } else {
            for filter in filters { set.formUnion(filter.photos) }
        }

        switch source {
        case .all: break
        case .favorites: break
        case .recent: set = set.filter { photo in photo.isRecent }
        case .selected: set = set.filter { photo in state.isSelected(photo) }
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
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                NavigationStack {
                    SidebarView()
                        .navigationTitle("Search and filter")
                        .toolbarTitleDisplayMode(.inline)
                }
            }
        }
        #if os(iOS) || os(tvOS)
            .tabBarMinimizeBehavior(.onScrollDown)
        #endif
    }
}
