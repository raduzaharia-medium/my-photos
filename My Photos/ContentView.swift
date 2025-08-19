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
    var tag: Tag? {
        if case let .edit(tag) = self { return tag }
        return nil
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    @State private var sidebarSelection: SidebarItem? = nil
    @State private var showAddSheet = false
    @State private var showImportFolder = false
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
            TagEditorSheet(
                editor.tag,
                onCancel: cancel,
                onSave: saveTag,
            )
        }
        .fileImporter(
            isPresented: $showImportFolder,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let folder = urls.first else { return }
            case .failure(let error):
                // TODO: surface a toast/alert
                print("Import failed: \(error)")
            }
        }
        .focusedValue(\.showImportFolder, $showImportFolder)
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
        withAnimation {
            editor = nil
        }
    }

    private func saveTag(_ tag: Tag?, name: String, kind: TagKind) {
        withAnimation {
            if let tag {
                tag.name = name
                tag.kind = kind
            } else {
                modelContext.insert(Tag(name: name, kind: kind))
            }

            self.editor = nil
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Tag.self, inMemory: true)
}
