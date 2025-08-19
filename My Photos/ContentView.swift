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
    @State private var showImportFolder = false
    @State private var pendingDelete: Tag?
    @State private var editor: TagEditor?

    var selectedTag: Tag? {
        if case .tag(let tag) = sidebarSelection { return tag }
        return nil
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $sidebarSelection,
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
        .alert(
            "Delete “\(pendingDelete?.name ?? "Tag")”?",
            isPresented: .init(
                get: { pendingDelete != nil },
                set: { if !$0 { pendingDelete = nil } }
            ),
            actions: {
                Button("Delete", role: .destructive) {
                    if let tag = pendingDelete {
                        deleteTag(tag)
                        pendingDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) { pendingDelete = nil }
            },
            message: {
                Text(
                    "This removes the tag from all photos. This can’t be undone."
                )
            }
        )
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
        .focusedValue(
            \.libraryActions,
            .init(
                importFolder: { showImportFolder = true },
                createTag: { editor = .create },
                editTag: { tag in editor = .edit(tag) },
                deleteTag: { tag in pendingDelete = tag }
            )
        )
        .focusedValue(\.selectedTag, selectedTag)
    }

    private func deleteTag(_ tag: Tag) {
        withAnimation {
            modelContext.delete(tag)
            sidebarSelection = nil
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
