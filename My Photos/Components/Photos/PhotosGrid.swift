import SwiftData
import SwiftUI

struct PhotosGrid: View {
    private static let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    @State private var isSelectionMode: Bool = false
    @State private var selectedPhotos: Set<Photo> = []

    private var photos: [Photo] {
        let result = allPhotos.filtered(by: sidebarSelection)
        guard isSelectionMode else { return result }
        guard selectionCategory == .selected else { return result }

        return result.filter { selectedPhotos.contains($0) }
    }
    private var selectionCategory: SelectionCategory
    private let sidebarSelection: Set<SidebarItem>

    init(
        _ sidebarSelection: Set<SidebarItem>,
        selectionCategory: SelectionCategory = .all
    ) {
        self.sidebarSelection = sidebarSelection
        self.selectionCategory = selectionCategory
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Self.columns, spacing: 8) {
                    ForEach(photos) { photo in
                        PhotosGridCell(
                            photo: photo,
                            isSelectionMode: isSelectionMode,
                            isSelected: selectionBinding(photo)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.all)
            }
            .preference(
                key: PhotosSelectionModePreferenceKey.self,
                value: isSelectionMode
            )
            .navigationTitle("Photos")
            .navigationDestination(for: Photo.self) { photo in
                let index = photos.firstIndex(of: photo) ?? 0
                PhotoNavigator(photos: photos, index: index)
            }
            .toolbar {
                PhotosGridToolbar(
                    isSelectionMode: $isSelectionMode,
                    selectedPhotos: $selectedPhotos
                )
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
