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
    @Environment(\.modelContext) private var ctx
    @Binding var selection: SidebarSelection
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    private var groups: [TagKind: [Tag]] {
        Dictionary(grouping: tags, by: { $0.kind }) as [TagKind: [Tag]]
    }

    var body: some View {
        List {
            ForEach(TagKind.allCases, id: \.self) { kind in
                let sectionTags = groups[kind] ?? []

                Section(kind.title) {
                    
                }
            }
        }
    }
}
