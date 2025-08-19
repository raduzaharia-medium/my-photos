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
}

struct SidebarView: View {
    let filters: [Filter]
    let tags: [Tag]
    let selection: Binding<SidebarItem?>

    let onAdd: () -> Void
    let onEdit: (Tag) -> Void
    let onDelete: (Tag) -> Void

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind })
    }
    
    init(_ filters: [Filter], _ tags: [Tag], _ selection: Binding<SidebarItem?>, onAdd: @escaping () -> Void, onEdit: @escaping (Tag) -> Void, onDelete: @escaping (Tag) -> Void) {
        self.filters = filters
        self.tags = tags
        self.selection = selection
        
        self.onAdd = onAdd
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    var body: some View {
        List(selection: selection) {
            Section("Filters") {
                ForEach(filters, id: \.self) { filter in
                    FilterRow(filter)
                }
            }

            ForEach(TagKind.allCases, id: \.self) { kind in
                let sectionTags = groups[kind] ?? []
                TagSection(
                    kind.title,
                    sectionTags,
                    onEdit: onEdit,
                    onDelete: onDelete
                )
            }
        }
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        #endif
        .toolbar {
            ToolbarItem {
                Button(action: onAdd) {
                    Label("Add Tag", systemImage: "plus")
                }
            }
        }
    }
}
