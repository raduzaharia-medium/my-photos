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

struct NewTagButton: View {
    @FocusedValue(\.libraryActions) private var actions

    var body: some View {
        Button {
            actions?.createTag()
        } label: {
            Label("New Tag", systemImage: "plus")
        }
        .disabled(actions == nil)
    }
}

struct SidebarView: View {
    @FocusedValue(\.libraryActions) private var actions

    let filters: [Filter]
    let tags: [Tag]
    let selection: Binding<SidebarItem?>

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind })
    }

    init(
        _ filters: [Filter],
        _ tags: [Tag],
        _ selection: Binding<SidebarItem?>,
    ) {
        self.filters = filters
        self.tags = tags
        self.selection = selection
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
                TagSection(kind.title, sectionTags)
            }
        }
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
        #endif
        .contextMenu(forSelectionType: SidebarItem.self) { items in
            if let tag = singleTag(from: items) {
                Button {
                    actions?.editTag(tag)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    actions?.deleteTag(tag)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .toolbar {
            ToolbarItem {
                NewTagButton()
            }
        }
    }

    private func singleTag(from items: Set<SidebarItem>) -> Tag? {
        guard items.count == 1, case let .tag(t) = items.first! else {
            return nil
        }

        return t
    }
}
