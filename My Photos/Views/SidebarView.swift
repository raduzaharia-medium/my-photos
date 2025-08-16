//
//  SidebarView.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftData
import SwiftUI

enum SidebarSelection: Hashable, Identifiable {
    case none
    case tag(PersistentIdentifier)

    var id: String {
        switch self {
        case .none: return "none"
        case .tag(let pid): return "tag-\(pid.hashValue)"
        }
    }
}

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selection: SidebarSelection
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind })
    }

    var body: some View {
        List {
            ForEach(TagKind.allCases, id: \.self) { kind in
                let sectionTags = groups[kind] ?? []

                Section(kind.title) {
                    ForEach(sectionTags, id: \.persistentModelID) { tag in
                        NavigationLink(tag.name) {
                            Text("Photos with tag \(tag.name)")
                        }
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
    }

    private func addTag() {
        withAnimation {
            let newTag = Tag(name: "Something", kind: .custom)

            modelContext.insert(newTag)
        }
    }
}
