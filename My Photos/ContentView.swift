//
//  ContentView.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    @State private var showAddSheet = false
    @State private var newTagName = ""
    @State private var newTagKind: TagKind = .custom

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
                    PhotosView(tagID: id)
                }
            }
        } detail: {
            Text("Select a tag").foregroundStyle(.secondary)
        }
        .sheet(isPresented: $showAddSheet) {
            CreateTagSheet(
                name: $newTagName,
                kind: $newTagKind,
                onCancel: { showAddSheet = false },
                onCreate: { name, kind in
                    modelContext.insert(Tag(name: name, kind: kind))
                    showAddSheet = false
                }
            )
            .frame(minWidth: 360)
        }
    }

    private func addTag() {
        withAnimation {
            newTagName = ""
            newTagKind = .custom
            showAddSheet = true
        }
    }

    private func editTag(_ tag: Tag) {
        withAnimation {
            newTagName = ""
            newTagKind = .custom
            showAddSheet = true
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
