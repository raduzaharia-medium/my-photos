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

struct SidebarSelectionFocusedKey: FocusedValueKey {
    typealias Value = Binding<Set<SidebarItem>>
}

extension FocusedValues {
    var sidebarSelection: Binding<Set<SidebarItem>>? {
        get { self[SidebarSelectionFocusedKey.self] }
        set { self[SidebarSelectionFocusedKey.self] = newValue }
    }
}


struct SidebarView: View {
    @EnvironmentObject private var tagSelectionModel: TagSelectionModel
    @State private var selection: Set<SidebarItem> = []

    let filters: [Filter]
    let tags: [Tag]

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
        .focusedValue(\.sidebarSelection, $selection)
        .onReceive(NotificationCenter.default.publisher(for: .resetTagSelection)) { _ in
            selection.removeAll()
        }
        .onAppear {
            DispatchQueue.main.async {
                self.selection = tagSelectionModel.selection
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            DispatchQueue.main.async { tagSelectionModel.selection = newValue }
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

