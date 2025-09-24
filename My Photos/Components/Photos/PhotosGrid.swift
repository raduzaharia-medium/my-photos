import SwiftData
import SwiftUI

struct PhotosGrid: View {
    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    @Environment(PresentationState.self) private var presentationState
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    var body: some View {
        let filteredPhotos = presentationState.getFilteredPhotos(allPhotos)

        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Self.columns, spacing: 8) {
                    ForEach(filteredPhotos) { photo in
                        if presentationState.isSelecting {
                            PhotoCard(
                                photo,
                                variant: .selectable,
                                isSelected: presentationState.isPhotoSelected(
                                    photo
                                )
                            )
                            .onTapGesture {
                                AppIntents.togglePhotoSelection(photo)
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
                PhotoNavigator(photos: filteredPhotos)
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
