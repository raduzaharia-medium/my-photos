import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @State private var path = NavigationPath()

    let photos: [Photo]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                MainPhotoGrid(photos: photos)
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
    var isPhotoSelected: Bool { presentationState.isSelected(photo) }
    var isSelected: Bool { allPhotosSelected || isPhotoSelected }

    var body: some View {
        PhotoCard(photo, variant: .selectable, isSelected: isSelected)
            .onTapGesture { AppIntents.togglePhotoSelection(photo) }
            .draggable(PhotoDragItem(photo.id)) {
                DragPreviewStack(count: presentationState.selectedPhotos.count)
            }
    }
}
