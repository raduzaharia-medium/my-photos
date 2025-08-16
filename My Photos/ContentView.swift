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

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(TagKind.allCases, id: \.self) { kind in
                    Section(kind.title) {
                        NavigationLink(tag.name) {
                            Text("Photos with tag \(tag.name)")
                        }
                    }
                }
            }
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            #endif
            .toolbar {
                #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                #endif
                ToolbarItem {
                    Button(action: addTag) {
                        Label("Add Tag", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addTag() {
        withAnimation {
            let newTag = Tag(name: "Holiday", kind: .event)

            modelContext.insert(newTag)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tags[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Tag.self, inMemory: true)
}
