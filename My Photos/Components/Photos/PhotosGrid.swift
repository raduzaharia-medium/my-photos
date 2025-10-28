import SwiftData
import SwiftUI

struct PhotosGrid: View {
    #if os(iOS)
        @Namespace private var transition
    #endif

    @State private var path = NavigationPath()

    let photos: [Photo]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                MainPhotoGrid(photos: photos) { photo in
                    path.append(photo)
                }
                #if os(iOS)
                    .matchedTransitionSource(id: "zoom", in: transition)
                #endif
            }
            .navigationDestination(for: Photo.self) { photo in
                PhotoViewer(photo: photo, photos: photos)
                    #if os(iOS)
                        .navigationTransition(
                            .zoom(sourceID: "zoom", in: transition)
                        )
                    #endif
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
                #if os(macOS) || os(iPadOS)
                    .gesture(
                        TapGesture().modifiers(.command).onEnded {
                            withAnimation {
                                AppIntents.toggleSelection(photo)
                            }
                        }
                    ).onTapGesture {
                        withAnimation { AppIntents.selectPhotos([photo]) }
                    }
                    .simultaneousGesture(
                        TapGesture(count: 2).onEnded { open(photo) }
                    )
                    .draggable(PhotoDragItem(photo.id)) {
                        DragPreviewStack(count: state.photoSelection.count)
                    }
                #endif
                #if os(iOS)
                    .onTapGesture { open(photo) }
                    .onLongPressGesture(minimumDuration: 0.3) {
                        withAnimation { AppIntents.selectPhotos([photo]) }
                    }
                #endif
        }
    }
}

private struct PhotoViewer: View {
    let photo: Photo
    let photos: [Photo]

    var body: some View {
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
}
