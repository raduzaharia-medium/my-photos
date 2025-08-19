import SwiftUI

struct LibraryWiring: ViewModifier {
    @Environment(\.modelContext) private var modelContext

    @ObservedObject var controller: LibraryController
    @Binding var sidebarSelection: SidebarItem?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                controller.setContext(modelContext)
            }
            .fileImporter(
                isPresented: $controller.showImportFolder,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false,
                onCompletion: controller.handleImportResult
            )
            .sheet(item: $controller.editor) { state in
                NavigationStack {
                    TagEditorSheet(
                        state.tag,
                        onCancel: { controller.editor = nil },
                        onSave: { original, name, kind in
                            controller.performSave(original: original, name: name, kind: kind)
                        }
                    )
                    .navigationTitle(state.tag == nil
                        ? "New Tag"
                        : "Edit Tag \(state.tag?.name ?? "")")
                }
            }
            .alert("Delete “\(controller.pendingDelete?.name ?? "Tag")”?",
                   isPresented: .init(
                       get: { controller.pendingDelete != nil },
                       set: { if !$0 { controller.pendingDelete = nil } }
                   )) {
                       Button("Delete", role: .destructive) {
                           controller.performDelete()
                           sidebarSelection = nil
                       }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes the tag from all photos.")
            }
            .focusedSceneValue(\.libraryActions, controller.actions)
            .focusedValue(\.selectedTag, {
                if case .tag(let t) = sidebarSelection { t } else { nil }
            }())
    }
}

extension View {
    func libraryWiring(_ controller: LibraryController,
                       selection: Binding<SidebarItem?>) -> some View {
        modifier(LibraryWiring(controller: controller, sidebarSelection: selection))
    }
}
