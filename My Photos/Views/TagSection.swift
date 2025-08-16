//
//  TagSection.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftUI

struct TagSection: View {
    let kind: TagKind
    let tags: [Tag]

    var onEdit: (Tag) -> Void
    var onDelete: (Tag) -> Void

    var body: some View {
        Section(kind.title) {
            ForEach(tags, id: \.persistentModelID) { tag in
                NavigationLink(
                    value: SidebarSelection.tag(tag.persistentModelID)
                ) {
                    TagRow(
                        tag: tag,
                        onEdit: onEdit,
                        onDelete: onDelete
                    )
                }
            }
        }
    }
}
