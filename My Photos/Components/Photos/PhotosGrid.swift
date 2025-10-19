import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Environment(PresentationState.self) private var presentationState
    @Query private var allPhotos: [Photo]

    let filters: Set<SidebarItem>

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
        NavigationStack {
            ScrollView {
                MainPhotoGrid(photos: photos)
            }
            .navigationDestination(for: Photo.self) { photo in
                PhotoNavigator()
                    .onAppear { AppIntents.navigateToPhoto(photo) }
                    .onDisappear { AppIntents.resetPhotoNavigation() }
            }
            .toolbar { PhotosGridToolbar() }
        }
    }
}

private struct MainPhotoGrid: View {
    @Environment(PresentationState.self) private var presentationState

    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    let photos: [Photo]

    var body: some View {
        LazyVGrid(columns: Self.columns, spacing: 8) {
            PhotoCards(photos: photos)
                .buttonStyle(.plain)
        }
        .padding(.all)
    }
}

private struct PhotoCards: View {
    @Environment(PresentationState.self) private var presentationState

    let photos: [Photo]

    var body: some View {
        ForEach(photos) { photo in
            if presentationState.isSelecting {
                SelectablePhotoCard(photo: photo)
            } else {
                NavigationLink(value: photo) {
                    PhotoCard(photo, variant: .grid)
                }
            }
        }
    }
}

private struct SelectablePhotoCard: View {
    @Environment(PresentationState.self) private var presentationState

    let photo: Photo

    var allPhotosSelected: Bool { presentationState.allPhotosSelected }
    var isPhotoSelected: Bool { presentationState.isPhotoSelected(photo) }
    var isSelected: Bool { allPhotosSelected || isPhotoSelected }

    var body: some View {
        PhotoCard(photo, variant: .selectable, isSelected: isSelected)
            .onTapGesture { AppIntents.togglePhotoSelection(photo) }
            .draggable(PhotoDragItem(photo.id)) {
                DragPreviewStack(count: presentationState.selectedPhotos.count)
            }
    }
}
