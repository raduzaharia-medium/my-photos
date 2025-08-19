import SwiftUI

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

struct SidebarWiring: ViewModifier {
    @FocusedValue(\.libraryActions) private var actions

    func body(content: Content) -> some View {
        content
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

extension View {
    func sidebarWiring() -> some View {
        modifier(SidebarWiring())
    }
}
