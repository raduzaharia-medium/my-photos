import SwiftUI

struct NewTagButton: View {
    @ObservedObject var sidebarState: SidebarState

    var body: some View {
        Button {
            sidebarState.showTagCreator()
        } label: {
            Label("New Tag", systemImage: "plus")
        }
    }
}

struct SidebarWiring: ViewModifier {
    @ObservedObject var sidebarState: SidebarState

    func body(content: Content) -> some View {
        content
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
            #endif
            .contextMenu(forSelectionType: SidebarItem.self) { items in
                if let tag = singleTag(from: items) {
                    Button {
                        sidebarState.selectTag(tag)
                        sidebarState.showTagEditor()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        sidebarState.selectTag(tag)
                        sidebarState.showDeleteTagAlert()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .sheet(item: $sidebarState.tagEditorMode) { state in
                NavigationStack {
                    TagEditorSheet(
                        state.tag,
                        onCancel: { sidebarState.dismissTagEditor() },
                        onSave: { original, name, kind in
                            sidebarState.saveTag(
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
            .fileImporter(
                isPresented: $sidebarState.folderSelectorVisible,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false,
                onCompletion: sidebarState.importFolder
            )
            .alert(
                "Delete “\(sidebarState.selectedTag?.name ?? "Tag")”?",
                isPresented: $sidebarState.deleteTagAlertVisible
            ) {
                Button("Delete", role: .destructive) {
                    sidebarState.deleteSelectedTag()
                }
                Button("Cancel", role: .cancel) {
                    sidebarState.dismissDeleteTagAlert()
                }
            } message: {
                Text("This removes the tag from all photos.")
            }
            .toolbar {
                ToolbarItem {
                    NewTagButton(sidebarState: sidebarState)
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
    func sidebarWiring(_ sidebarState: SidebarState) -> some View {
        modifier(SidebarWiring(sidebarState: sidebarState))
    }
}
