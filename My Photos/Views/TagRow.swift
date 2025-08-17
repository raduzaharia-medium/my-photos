//
//  TagRow.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftData
import SwiftUI

struct TagRow: View {
    let tag: Tag
    var onEdit: (Tag) -> Void
    var onDelete: (Tag) -> Void

    var body: some View {
        HStack {
            Label(tag.name, systemImage: tag.kind.icon)
            Spacer(minLength: 8)

        }
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                onEdit(tag)
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete(tag)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
