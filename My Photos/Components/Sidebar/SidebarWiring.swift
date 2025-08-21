import SwiftUI

struct SidebarWiring: ViewModifier {
    @ObservedObject var tagViewModel: TagViewModel

    func body(content: Content) -> some View {
        content
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
            #endif
            .sheet(item: $tagViewModel.tagEditorMode) { state in
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
