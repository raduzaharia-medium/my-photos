import SwiftUI

struct SidebarView: View {
    @State private var selection: Set<SidebarItem> = []

    private let filters: [Filter]
    private let tags: [Tag]

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind })
    }

    init(
        _ filters: [Filter],
        _ tags: [Tag],
    ) {
        self.filters = filters
        self.tags = tags
    }

    var body: some View {
        List(selection: $selection) {
            Section("Filters") {
                ForEach(filters, id: \.self) { filter in
                    SidebarRow(.filter(filter))
                }
            }

            ForEach(TagKind.allCases, id: \.self) { kind in
                let sectionTags = groups[kind] ?? []

                if !sectionTags.isEmpty {
                    Section(kind.title) {
                        ForEach(sectionTags, id: \.persistentModelID) { tag in
                            SidebarRow(.tag(tag))
                        }
                    }
                }
            }
        }
        .task {
            AppIntents.resetTagSelection()
        }
        .focusedValue(\.sidebarSelection, $selection)
        .onReceive(
            NotificationCenter.default.publisher(for: .resetTagSelection)
        ) { _ in
            selection.removeAll()

            if let firstFilter = filters.first {
                selection = [SidebarItem.filter(firstFilter)]
            }
        }
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
        #endif
        .contextMenu(forSelectionType: SidebarItem.self) { items in
            TagContextMenu(items)
        }
        .toolbar {
            TagToolbar()
        }
    }
}
