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

    #if os(macOS)
        @State private var hovered = false
    #endif

    var body: some View {
        HStack {
            Label(tag.name, systemImage: tag.kind.icon)
            Spacer(minLength: 8)

            #if os(macOS)
                if hovered {
                    Button {
                        onEdit(tag)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            #endif
        }
        .contentShape(Rectangle())
        #if os(macOS)
            .onHover { hovered = $0 }
            .animation(.easeOut(duration: 0.12), value: hovered)
        #else
            .swipeActions {
                Button("Edit") { onEdit(tag) }.tint(.blue)
                Button(role: .destructive) {
                    onDelete(tag)
                } label: {
                    Text("Delete")
                }
            }
        #endif
    }
}
