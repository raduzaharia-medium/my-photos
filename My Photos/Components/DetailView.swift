import SwiftData
import SwiftUI

enum SelectionCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case selected = "Selected"
    
    var id: String { rawValue }
}

struct DetailView: View {
    @FocusedBinding(\.sidebarSelection) private var selection
    
    @State private var presentationMode: PresentationMode = .grid
    @State private var isPhotosSelectionMode: Bool = false
    @State private var selectionCategory: SelectionCategory = .all

    var body: some View {
        Group {
            switch presentationMode {
            case .grid: PhotosGrid(selection ?? [], selectionCategory: selectionCategory)
            case .map: PhotosMap(selection ?? [])
            }
        }
        .onPreferenceChange(PhotosSelectionModePreferenceKey.self) { newValue in
            isPhotosSelectionMode = newValue
            if newValue && presentationMode == .map {
                presentationMode = .grid
            }
        }
        .toolbar {
            DetailViewToolbar(
                isSelectionMode: $isPhotosSelectionMode,
                selectionCategory: $selectionCategory,
                presentationMode: $presentationMode
            )
        }
        .focusedValue(\.presentationMode, $presentationMode)
//        .navigationTitle(
//            ((selection?.allTags.count ?? 0) > 1)
//                ? "Multiple Collections"
//                : (selection?.singleTag?.name ?? "All Photos")
//        )
    }
}
