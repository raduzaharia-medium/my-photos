import SwiftData
import SwiftUI

struct PhotosGrid: View {
    #if os(iOS) || os(iPadOS)
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
                #if os(iOS) || os(iPadOS)
                    .matchedTransitionSource(id: "zoom", in: transition)
                #endif
            }
            .navigationDestination(for: Photo.self) { photo in
                PhotoViewer(photo: photo, photos: photos)
                    #if os(iOS) || os(iPadOS)
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
                #if os(macOS)
                    .modifier(DesktopModifiers(photo: photo, open: open))
                #endif
                #if os(iOS) || os(iPadOS)
                    .modifier(MobileModifiers(photo: photo, open: open))
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

#if os(macOS)
    private struct DesktopModifiers: ViewModifier {
        @Environment(PresentationState.self) private var state

        let photo: Photo
        let open: (Photo) -> Void

        func body(content: Content) -> some View {
            content.gesture(
                TapGesture().modifiers(.command).onEnded {
                    withAnimation {
                        PhotoIntents.toggleSelection(photo)
                    }
                }
            ).onTapGesture {
                withAnimation { PhotoIntents.select(photo) }
            }
            .simultaneousGesture(
                TapGesture(count: 2).onEnded { open(photo) }
            )
            .draggable(PhotoDragItem(photo.id)) {
                DragPreviewStack(count: state.photoSelection.count)
            }
        }
    }
#endif

#if os(iOS) || os(iPadOS)
    private struct MobileModifiers: ViewModifier {
        @Environment(PresentationState.self) private var state

        let photo: Photo
        let open: (Photo) -> Void

        func body(content: Content) -> some View {
            content.onTapGesture {
                if state.photoSelectionMode {
                    PhotoIntents.toggleSelection(photo)
                } else {
                    open(photo)
                }
            }
            .onLongPressGesture(minimumDuration: 0.3) {
                withAnimation {
                    PhotoIntents.enableSelectionMode()
                    PhotoIntents.select(photo)
                }
            }
        }
    }
#endif
