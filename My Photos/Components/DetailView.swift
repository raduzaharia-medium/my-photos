import SwiftData
import SwiftUI

enum SelectionCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case selected = "Selected"

    var id: String { rawValue }
}

struct DetailView: View {
    @Environment(PresentationState.self) private var presentationState

    @State private var presentationMode: PresentationMode = .grid
    @State private var selectionCategory: SelectionCategory = .all

    var body: some View {
        Group {
            switch presentationMode {
            case .grid: PhotosGrid(selectionCategory: selectionCategory)
            case .map: PhotosMap(presentationState.photoFilter)
            }
        }
        .toolbar {
            DetailViewToolbar(
                selectionCategory: $selectionCategory,
                presentationMode: $presentationMode
            )
        }
        .focusedValue(\.presentationMode, $presentationMode)
        .navigationTitle(
            (presentationState.selectedTags.count > 1)
                ? "Multiple Collections"
                : (presentationState.selectedTags.first?.name ?? "All Photos")
        )
    }
}
