import SwiftUI

struct NewTagButton: View {
    @ObservedObject var tagViewModel: TagViewModel

    init(_ tagViewModel: TagViewModel) {
        self.tagViewModel = tagViewModel
    }

    var body: some View {
        Button {
            tagViewModel.showTagCreator()
        } label: {
            Label("New Tag", systemImage: "plus")
        }
    }
}

struct SidebarWiring: ViewModifier {
    @ObservedObject var tagViewModel: TagViewModel
    @ObservedObject var alertViewModel: AlertViewModel

    func body(content: Content) -> some View {
        content
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
            #endif
            .contextMenu(forSelectionType: SidebarItem.self) { items in
                if let tag = singleTag(from: items) {
                    Button {
                        tagViewModel.selectItem(.tag(tag))
                        tagViewModel.showTagEditor()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        tagViewModel.selectItem(.tag(tag))
                        tagViewModel.deleteSelectedTag()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .sheet(item: $tagViewModel.tagEditorMode) { state in
                NavigationStack {
                    TagEditorSheet(
                        state.tag,
                        onCancel: { tagViewModel.dismissTagEditor() },
                        onSave: { original, name, kind in
                            tagViewModel.saveTag(
                                original: original,
                                name: name,
                                kind: kind
                            )
                        }
                    )
                    .navigationTitle(
                        state.tag == nil
                            ? "New Tag"
                            : "Edit Tag \(state.tag?.name ?? "")"
                    )
                }
            }
            .toolbar {
                ToolbarItem {
                    NewTagButton(tagViewModel)
                }
            }
    }

    private func singleTag(from items: Set<SidebarItem>) -> Tag? {
        guard items.count == 1, case let .tag(t) = items.first else {
            return nil
        }

        return t
    }

}

extension View {
    func sidebarWiring(
        tagViewModel: TagViewModel,
        alertViewModel: AlertViewModel
    ) -> some View {
        modifier(
            SidebarWiring(
                tagViewModel: tagViewModel,
                alertViewModel: alertViewModel
            )
        )
    }
}
