import SwiftData
import SwiftUI

enum DetailTab: String, CaseIterable, Identifiable {
    case photos = "Grid"
    case map = "Map"

    var id: String { rawValue }
}

struct DetailView: View {
    @EnvironmentObject private var tagSelectionModel: TagSelectionModel
    @State private var tab: DetailTab = .photos

    var body: some View {
        Group {
            switch tab {
            case .photos: PhotosGrid(tagSelectionModel.selection)
            case .map: PhotosMap(tagSelectionModel.selection)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker(
                    "Tab",
                    selection: Binding($tab)
                ) {
                    ForEach(DetailTab.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .help("Change how this tag is displayed")
            }
        }
        .navigationTitle(
            tagSelectionModel.selection.count > 1
                ? "Multiple Collections"
                : (tagSelectionModel.singleTag?.name ?? "All Photos")
        )
    }
}
