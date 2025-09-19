import SwiftData
import SwiftUI

enum DetailTab: String, CaseIterable, Identifiable {
    case photos = "Grid"
    case map = "Map"

    var id: String { rawValue }
}

struct DetailView: View {
    @FocusedBinding(\.sidebarSelection) private var selection
    @State private var tab: DetailTab = .photos

    var body: some View {
        Group {
            switch tab {
            case .photos: PhotosGrid(selection ?? [])
            case .map: PhotosMap(selection ?? [])
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
            ((selection?.allTags.count ?? 0) > 1)
                ? "Multiple Collections"
                : (selection?.singleTag?.name ?? "All Photos")
        )
    }
}
