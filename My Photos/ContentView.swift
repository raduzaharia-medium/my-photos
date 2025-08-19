import SwiftData
import SwiftUI

private enum TagEditor: Identifiable {
    case create
    case edit(Tag)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let tag): return "edit-\(tag.persistentModelID)"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    @State private var sidebarSelection: SidebarItem? = nil
    @State private var showAddSheet = false
    @State private var editor: TagEditor?

    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $sidebarSelection,
                onAdd: addTag,
                onEdit: editTag,
                onDelete: deleteTag
            )
        } detail: {
            DetailView(sidebarSelection)
        }
        .sheet(item: $editor) { editor in
            switch editor {
            case .create:
                TagEditorSheet(
                    title: "New Tag",
                    initialName: "",
                    initialKind: .custom,
                    onCancel: cancel,
                    onSave: saveCreate
                )
            case .edit(let tag):
                TagEditorSheet(
                    title: "Edit Tag \"\(tag.name)\"",
                    initialName: tag.name,
                    initialKind: tag.kind,
                    onCancel: cancel,
                    onSave: { name, kind in
                        saveEdit(tag, name: name, kind: kind)
                    }
                )
            }
        }
    }

    private func addTag() {
        withAnimation {
            editor = .create
        }
    }

    private func editTag(_ tag: Tag) {
        withAnimation {
            editor = .edit(tag)
        }
    }

    private func deleteTag(_ tag: Tag) {
        withAnimation {
            modelContext.delete(tag)
        }
    }

    private func cancel() {
        editor = nil
    }

    private func saveCreate(name: String, kind: TagKind) {
        modelContext.insert(Tag(name: name, kind: kind))
        self.editor = nil
    }

    private func saveEdit(_ tag: Tag, name: String, kind: TagKind) {
        tag.name = name
        tag.kind = kind
        self.editor = nil
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Tag.self, inMemory: true)
}
