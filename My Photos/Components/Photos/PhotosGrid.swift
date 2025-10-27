import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @State private var path = NavigationPath()
    @State private var selection = Set<Photo>()

    let photos: [Photo]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                MainPhotoGrid(selection: $selection, photos: photos) { photo in
                    path.append(photo)
                }.onChange(of: selection) {
                    AppIntents.selectPhotos(Array(selection))
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
            .onChange(of: photos) { path.removeLast(path.count) }
        }
    }
}

private struct MainPhotoGrid: View {
    @Binding var selection: Set<Photo>

    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    let photos: [Photo]
    let open: (Photo) -> Void

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            PhotoCards(selection: $selection, photos: photos, open: open)
                .buttonStyle(.plain)
        }
        .padding(.all)
    }
}

private struct PhotoCards: View {
    @Binding var selection: Set<Photo>

    let photos: [Photo]
    let open: (Photo) -> Void

    var allSelected: Bool { selection.count == photos.count }

    var body: some View {
        ForEach(photos) { photo in
            var isSelected: Bool { selection.contains(photo) || allSelected }

            PhotoCard(photo, variant: .grid, isSelected: isSelected)
                .contentShape(Rectangle())
                .gesture(
                    TapGesture().modifiers(.command).onEnded {
                        if selection.contains(photo) {
                            selection.remove(photo)
                        } else {
                            selection.insert(photo)
                        }
                    }
                )
                .onTapGesture { selection = [photo] }.simultaneousGesture(
                    TapGesture(count: 2).onEnded { open(photo) }
                )
                .draggable(PhotoDragItem(photo.id)) {
                    DragPreviewStack(count: selection.count)
                }
        }
    }
}
