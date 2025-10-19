import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Environment(PresentationState.self) private var presentationState
    @Query(sort: [SortDescriptor(\Photo.dateTaken, order: .reverse)]) private
        var allPhotos: [Photo]

    let filters: Set<SidebarItem>

    private var photos: [Photo] {
        var set = Set<Photo>()

        if filters.selectedFilters.count == filters.count { return allPhotos }

        for filter in filters { set.formUnion(filter.photos) }
        return Array(set).sorted {
            $0.dateTaken ?? .distantFuture > $1.dateTaken ?? .distantFuture
        }
    }

    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Self.columns, spacing: 8) {
                    ForEach(photos) { photo in
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
                                DragPreviewStack(
                                    count: presentationState.selectedPhotos
                                        .count
                                )
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
        }
    }
}
