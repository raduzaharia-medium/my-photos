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

    func body(content: Content) -> some View {
        content
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
            #endif
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
}

extension View {
    func sidebarWiring(tagViewModel: TagViewModel) -> some View {
        modifier(
            SidebarWiring(tagViewModel: tagViewModel)
        )
    }
}
