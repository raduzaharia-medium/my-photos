import SwiftUI

struct TagRow: View {
    let tag: Tag
    let onEdit: (Tag) -> Void
    let onDelete: (Tag) -> Void

    init(
        _ tag: Tag,
        onEdit: @escaping (Tag) -> Void,
        onDelete: @escaping (Tag) -> Void
    ) {
        self.tag = tag
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationLink(value: SidebarItem.tag(tag)) {
            HStack {
                Label(tag.name, systemImage: tag.kind.icon)
                Spacer(minLength: 8)
            }
            .contentShape(Rectangle())
        }
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
