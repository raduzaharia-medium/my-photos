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
    let tags: [Tag]

    let onAdd: () -> Void
    let onEdit: (Tag) -> Void
    let onDelete: (Tag) -> Void

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind })
    }

    var body: some View {
        List {
            Section("Filters") {
                ForEach(Filter.allCases, id: \.self) { filter in
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
        .navigationDestination(for: SidebarItem.self) { selection in
            DetailView(selection)
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
