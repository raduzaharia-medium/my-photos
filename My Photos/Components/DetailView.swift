import SwiftData
import SwiftUI

enum PresentationType: String, CaseIterable, Identifiable {
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
    @State private var presentationType: PresentationType = .photos
    @State private var isPhotosSelectionMode: Bool = false
    @State private var selectionCategory: SelectionCategory = .all

    var body: some View {
        Group {
            switch presentationType {
            case .photos: PhotosGrid(selection ?? [], selectionCategory: selectionCategory)
            case .map: PhotosMap(selection ?? [])
            }
        }
        .onPreferenceChange(PhotosSelectionModePreferenceKey.self) { newValue in
            isPhotosSelectionMode = newValue
            if newValue && presentationType == .map {
                presentationType = .photos
            }
        }
        .toolbar {
            DetailViewToolbar(
                isSelectionMode: $isPhotosSelectionMode,
                selectionCategory: $selectionCategory,
                presentationType: $presentationType
            )
        }
        .navigationTitle(
            ((selection?.allTags.count ?? 0) > 1)
                ? "Multiple Collections"
                : (selection?.singleTag?.name ?? "All Photos")
        )
    }
}
