import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @State private var path = NavigationPath()

    let photos: [Photo]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                MainPhotoGrid(photos: photos) { photo in
                    path.append(photo)
                }
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
            .onChange(of: photos) {
                withAnimation { path.removeLast(path.count) }
            }
        }
    }
}

private struct MainPhotoGrid: View {
    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    let photos: [Photo]
    let open: (Photo) -> Void

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            PhotoCards(photos: photos, open: open)
                .buttonStyle(.plain)
        }
        .padding(.all)
    }
}

private struct PhotoCards: View {
    @Environment(PresentationState.self) private var state

    let photos: [Photo]
    let open: (Photo) -> Void

    var body: some View {
        ForEach(photos) { photo in
            var isSelected: Bool { state.isSelected(photo) }

            PhotoCard(photo, variant: .grid, isSelected: isSelected)
                .contentShape(Rectangle())
                .gesture(
                    TapGesture().modifiers(.command).onEnded {
                        withAnimation {
                            AppIntents.toggleSelection(photo)
                        }
                    }
                )
                .onTapGesture {
                    withAnimation { AppIntents.selectPhotos([photo]) }
                }
                .simultaneousGesture(
                    TapGesture(count: 2).onEnded { open(photo) }
                )
                .draggable(PhotoDragItem(photo.id)) {
                    DragPreviewStack(count: state.photoSelection.count)
                }
        }
    }
}
