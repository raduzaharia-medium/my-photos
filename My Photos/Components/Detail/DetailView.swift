import SwiftData
import SwiftUI

enum DetailTab: String, CaseIterable, Identifiable {
    case photos = "Grid"
    case map = "Map"

    var id: String { rawValue }
}

struct DetailView: View {
    @State private var tab: DetailTab = .photos
    let sidebarSelection: Set<SidebarItem>

    init(_ sidebarSelection: Set<SidebarItem>) {
        self.sidebarSelection = sidebarSelection
    }
    
    var body: some View {
        Group {
            switch tab {
            case .photos: PhotosGrid(sidebarSelection)
            case .map: PhotosMap(sidebarSelection)
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
        .navigationTitle(sidebarSelection.first?.name ?? "All Photos")
    }
}
