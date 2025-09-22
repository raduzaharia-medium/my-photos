import SwiftData
import SwiftUI

enum DetailTab: String, CaseIterable, Identifiable {
    case photos = "Grid"
    case map = "Map"

    var id: String { rawValue }
}

enum SelectionCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case selected = "Selected"
    
    var id: String { rawValue }
}

struct DetailView: View {
    @FocusedBinding(\.sidebarSelection) private var selection
    @State private var tab: DetailTab = .photos
    @State private var isPhotosSelectionMode: Bool = false
    @State private var selectionCategory: SelectionCategory = .all

    var body: some View {
        Group {
            switch tab {
            case .photos: PhotosGrid(selection ?? [], selectionCategory: selectionCategory)
            case .map: PhotosMap(selection ?? [])
            }
        }
        .onPreferenceChange(PhotosSelectionModePreferenceKey.self) { newValue in
            isPhotosSelectionMode = newValue
            if newValue && tab == .map {
                tab = .photos
            }
        }
        .toolbar {
            DetailViewToolbar(
                isSelectionMode: $isPhotosSelectionMode,
                selectionCategory: $selectionCategory,
                tab: $tab
            )
        }
        .navigationTitle(
            ((selection?.allTags.count ?? 0) > 1)
                ? "Multiple Collections"
                : (selection?.singleTag?.name ?? "All Photos")
        )
    }
}
