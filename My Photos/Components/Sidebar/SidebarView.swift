import SwiftUI

enum SidebarItem: Hashable {
    case filter(Filter)
    case tag(Tag)

    var name: String {
        switch self {
        case .filter(let filter):
            return filter.name
        case .tag(let tag):
            return tag.name
        }
    }

    var icon: String {
        switch self {
        case .filter(let f): return f.icon
        case .tag(let t): return t.kind.icon
        }
    }
}

struct SidebarView: View {
    @ObservedObject var tagViewModel: TagViewModel

    let filters: [Filter]
    let tags: [Tag]
    let selection: Binding<Set<SidebarItem>>

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind })
    }

    init(
        _ filters: [Filter],
        _ tags: [Tag],
        _ selection: Binding<Set<SidebarItem>>,
        tagViewModel: TagViewModel
    ) {
        self.filters = filters
        self.tags = tags
        self.selection = selection
        self.tagViewModel = tagViewModel
    }

    var body: some View {
        List(selection: selection) {
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
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
        #endif
        .contextMenu(forSelectionType: SidebarItem.self) { items in
            TagContextMenu(items, tagViewModel)
        }
        .toolbar {
            TagToolbar(tagViewModel: tagViewModel)
        }
    }
}
