//
//  ContentView.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftData
import SwiftUI

enum TagSelection: Hashable {
    case tag(PersistentIdentifier)
}

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

    @State private var showAddSheet = false
    @State private var editor: TagEditor?

    var body: some View {
        NavigationSplitView {
            SidebarView(
                tags: tags,
                onAdd: addTag,
                onEdit: editTag,
                onDelete: deleteTag
            )
            .navigationDestination(for: TagSelection.self) { sel in
                switch sel {
                case .tag(let id):
                    DetailView(tagID: id)
                }
            }
        } detail: {
            Text("Select a tag").foregroundStyle(.secondary)
        }
        .sheet(item: $editor) { editor in
            switch editor {
            case .create:
                TagEditorSheet(
                    title: "New Tag",
                    initialName: "",
                    initialKind: .custom,
                    onCancel: { self.editor = nil },
                    onSave: { name, kind in
                        modelContext.insert(Tag(name: name, kind: kind))
                        self.editor = nil
                    }
                )
            case .edit(let tag):
                TagEditorSheet(
                    title: "Edit Tag \"\(tag.name)\"",
                    initialName: tag.name,
                    initialKind: tag.kind,
                    onCancel: { self.editor = nil },
                    onSave: { name, kind in
                        tag.name = name
                        tag.kind = kind
                        self.editor = nil
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
}

#Preview {
    ContentView()
        .modelContainer(for: Tag.self, inMemory: true)
}
