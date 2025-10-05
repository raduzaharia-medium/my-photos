import SwiftUI

struct PhotosGrid: View {
    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    @Environment(PresentationState.self) private var presentationState

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Self.columns, spacing: 8) {
                    ForEach(presentationState.filteredPhotos) { photo in
                        if presentationState.isSelecting {
                            PhotoCard(
                                photo,
                                variant: .selectable,
                                isSelected: presentationState.allPhotosSelected
                                    || presentationState.isPhotoSelected(photo)
                            )
                            .onTapGesture {
                                AppIntents.togglePhotoSelection(photo)
                            }
                            .draggable(PhotoDragItem(photo.id)) {
                                DragPreviewStack(count: presentationState.selectedPhotos.count)
                            }
                        } else {
                            NavigationLink(value: photo) {
                                PhotoCard(photo, variant: .grid)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.all)
            }
            .navigationDestination(for: Photo.self) { photo in
                PhotoNavigator()
                    .onAppear {
                        AppIntents.navigateToPhoto(photo)
                    }
                    .onDisappear {
                        AppIntents.resetPhotoNavigation()
                    }
            }
            .toolbar {
                PhotosGridToolbar()
            }
            .setupPhotoSelectionHandlers(presentationState: presentationState)
        }
    }
}

