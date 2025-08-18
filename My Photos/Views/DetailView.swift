import SwiftData
import SwiftUI

enum DetailTab: String, CaseIterable, Identifiable {
    case photos = "Grid"
    case map = "Map"

    var id: String { rawValue }
}

struct DetailView: View {
    @State private var tab: DetailTab = .photos
    let selectedItem: SidebarItem?

    init(_ selectedItem: SidebarItem?) {
        self.selectedItem = selectedItem
    }
    
    var body: some View {
        Group {
            switch tab {
            case .photos: PhotosGrid(selectedItem)
            case .map: PhotosMap(selectedItem)
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
    }
}
