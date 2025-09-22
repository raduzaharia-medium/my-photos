import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @State private var isSelectionMode: Bool = false
    @State private var selectedPhotos: Set<Photo> = []

    var selectionCategory: SelectionCategory

    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    let sidebarSelection: Set<SidebarItem>

    private var photos: [Photo] {
        let base = allPhotos.filtered(by: sidebarSelection)
        if isSelectionMode {
            switch selectionCategory {
            case .all:
                return base
            case .selected:
                return base.filter { selectedPhotos.contains($0) }
            }
        } else {
            return base
        }
    }
    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    init(_ sidebarSelection: Set<SidebarItem>, selectionCategory: SelectionCategory = .all) {
        self.sidebarSelection = sidebarSelection
        self.selectionCategory = selectionCategory
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(photos) { photo in
                        if isSelectionMode {
                            PhotoCard(
                                photo,
                                variant: .selectable,
                                isSelected: bindingForPhotoSelection(photo)
                            )
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
            .preference(key: PhotosSelectionModePreferenceKey.self, value: isSelectionMode)
            .navigationTitle("Photos")
            .navigationDestination(for: Photo.self) { photo in
                if isSelectionMode {
                    EmptyView()
                } else {
                    let index = photos.firstIndex(of: photo) ?? 0
                    PhotoNavigator(photos: photos, index: index)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    HStack(spacing: 6) {
                        Image(
                            systemName: isSelectionMode
                                ? "checkmark.circle.fill"
                                : "checkmark.circle.badge.plus"
                        )
                        .help(
                            isSelectionMode
                                ? "Exit selection mode" : "Enter selection mode"
                        )

                        Toggle(isOn: $isSelectionMode) { EmptyView() }
                            .toggleStyle(.switch)
                            .controlSize(.small)
                            .onChange(of: isSelectionMode) { _, newValue in
                                if !newValue {
                                    selectedPhotos.removeAll()
                                }
                            }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }

    private func bindingForPhotoSelection(_ photo: Photo) -> Binding<Bool> {
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

