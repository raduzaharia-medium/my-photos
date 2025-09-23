import SwiftData
import SwiftUI

struct PhotosGrid: View {
    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    @Environment(PresentationState.self) private var presentationState
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    private var photos: [Photo] {
        let result = allPhotos.filtered(by: presentationState.photoFilter)
        guard presentationState.isSelecting else { return result }
        guard presentationState.showOnlySelected else { return result }

        return result.filter { presentationState.selectedPhotos.contains($0) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Self.columns, spacing: 8) {
                    ForEach(photos) { photo in
                        if presentationState.isSelecting {
                            PhotoCard(
                                photo,
                                variant: .selectable,
                                isSelected: presentationState.isPhotoSelected(photo)
                            )
                            .onTapGesture {
                                AppIntents.togglePhotoSelection(photo)
                            }
                        } else {
                            NavigationLink(value: photo) {
                                PhotoCard(photo, variant: .grid)
                            }
                        }                    }
                    .buttonStyle(.plain)
                }
                .padding(.all)
            }
            .navigationDestination(for: Photo.self) { photo in
                let index = photos.firstIndex(of: photo) ?? 0
                PhotoNavigator(photos: photos, index: index)
            }
            .toolbar {
                PhotosGridToolbar()
            }
            .setupPhotoSelectionHandlers(presentationState: presentationState)
        }
    }
}
