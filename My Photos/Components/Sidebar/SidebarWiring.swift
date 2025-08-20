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

    init(_ tagViewModel: TagViewModel) {
        self.tagViewModel = tagViewModel
    }
    
    func body(content: Content) -> some View {
        content
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
            #endif
            .contextMenu(forSelectionType: SidebarItem.self) { items in
                if let tag = singleTag(from: items) {
                    Button {
                        tagViewModel.selectTag(tag)
                        tagViewModel.showTagEditor()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        tagViewModel.selectTag(tag)
                        tagViewModel.showDeleteTagAlert()
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
            .alert(
                "Delete “\(tagViewModel.selectedTag?.name ?? "Tag")”?",
                isPresented: $tagViewModel.deleteTagAlertVisible
            ) {
                Button("Delete", role: .destructive) {
                    tagViewModel.deleteSelectedTag()
                }
                Button("Cancel", role: .cancel) {
                    tagViewModel.dismissDeleteTagAlert()
                }
            } message: {
                Text("This removes the tag from all photos.")
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
    func sidebarWiring(_ tagViewModel: TagViewModel) -> some View {
        modifier(SidebarWiring(tagViewModel))
    }
}
