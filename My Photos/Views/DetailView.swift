import SwiftData
import SwiftUI

enum DetailTab: String, CaseIterable, Identifiable {
    case photos = "Grid"
    case map = "Map"

    var id: String { rawValue }
}

struct DetailView: View {
    @State private var tab: DetailTab = .photos
    let tag: Tag?

    var body: some View {
        Group {
            switch tab {
            case .photos: PhotosGrid(tag: tag)
            case .map: PhotosMap(tag: tag)
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
