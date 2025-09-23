import SwiftData
import SwiftUI

struct PhotosGrid: View {
    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    @Environment(PresentationState.self) private var presentationState
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]
    @State private var selectedPhotos: Set<Photo> = []

    private var photos: [Photo] {
        let result = allPhotos.filtered(by: presentationState.photoFilter)
        guard presentationState.isSelecting else { return result }
        guard selectionCategory == .selected else { return result }

        return result.filter { selectedPhotos.contains($0) }
    }
    private var selectionCategory: SelectionCategory

    init(selectionCategory: SelectionCategory = .all) {
        self.selectionCategory = selectionCategory
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Self.columns, spacing: 8) {
                    ForEach(photos) { photo in
                        PhotosGridCell(
                            photo: photo,
                            isSelected: selectionBinding(photo)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.all)
            }
            .navigationDestination(for: Photo.self) { photo in
                let index = photos.firstIndex(of: photo) ?? 0
                PhotoNavigator(photos: photos, index: index)
            }
            .toolbar {
                PhotosGridToolbar(selectedPhotos: $selectedPhotos)
            }
        }
    }

    private func selectionBinding(_ photo: Photo) -> Binding<Bool> {
        Binding<Bool>(
            get: { selectedPhotos.contains(photo) },
            set: { newValue in
                if newValue {
                    selectedPhotos.insert(photo)
                } else {
                    selectedPhotos.remove(photo)
                }
            }
        )
    }
}
