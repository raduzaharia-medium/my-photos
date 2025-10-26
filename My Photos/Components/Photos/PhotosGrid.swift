import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @State private var path = NavigationPath()

    let photos: [Photo]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                MainPhotoGrid(photos: photos) { photo in path.append(photo) }
            }
            .navigationDestination(for: Photo.self) { photo in
                if let index = photos.firstIndex(of: photo), !photos.isEmpty {
                    PhotoNavigator(photos, index: index)
                } else {
                    ContentUnavailableView(
                        "Photo unavailable",
                        systemImage: "exclamationmark.triangle",
                        description: Text("This photo can’t be opened.")
                    )
                }
            }
            .toolbar { PhotosGridToolbar(photos: photos) }
            .onChange(of: photos) { path.removeLast(path.count) }
        }
    }
}

private struct MainPhotoGrid: View {
    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    let photos: [Photo]
    let open: (Photo) -> Void

    var body: some View {
        LazyVGrid(columns: Self.columns, spacing: 8) {
            PhotoCards(photos: photos, open: open)
                .buttonStyle(.plain)
        }
        .padding(.all)
    }
}

private struct PhotoCards: View {
    @Environment(PresentationState.self) private var presentationState

    let photos: [Photo]
    let open: (Photo) -> Void

    var body: some View {
        ForEach(photos) { photo in
            SelectablePhotoCard(photo: photo)
                .contentShape(Rectangle())
                .onTapGesture { AppIntents.togglePhotoSelection(photo) }
                .onTapGesture(count: 2) { open(photo) }
                .draggable(PhotoDragItem(photo.id)) {
                    DragPreviewStack(
                        count: presentationState.photoSelection.count
                    )
                }
        }
    }
}

private struct SelectablePhotoCard: View {
    @Environment(PresentationState.self) private var presentationState

    let photo: Photo

    var allPhotosSelected: Bool { presentationState.allPhotosSelected }
    var isPhotoSelected: Bool { presentationState.isSelected(photo) }
    var isSelected: Bool { allPhotosSelected || isPhotoSelected }
    var variant: PhotoCardVariant {
        presentationState.isSelecting ? .selectable : .grid
    }

    var body: some View {
        PhotoCard(photo, variant: variant, isSelected: isSelected)
    }
}
