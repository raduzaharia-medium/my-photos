//
//  SidebarView.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftData
import SwiftUI

enum SidebarSelection: Hashable {
    case tag(PersistentIdentifier)
}

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selection: SidebarSelection?
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    let onAdd: () -> Void
    let onEdit: (Tag) -> Void
    let onDelete: (Tag) -> Void

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind })
    }

    var body: some View {
        List {
            ForEach(TagKind.allCases, id: \.self) { kind in
                let sectionTags = groups[kind] ?? []
                TagSection(
                    kind: kind,
                    tags: sectionTags,
                    onEdit: onEdit,
                    onDelete: onDelete
                )
            }
        }
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        #endif
        .toolbar {
            ToolbarItem {
                Button(action: onAdd) {
                    Label("Add Tag", systemImage: "plus")
                }
            }
        }
    }
}
