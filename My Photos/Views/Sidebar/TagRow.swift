import SwiftUI

struct TagRow: View {
    @FocusedValue(\.libraryActions) private var actions

    let tag: Tag

    init(
        _ tag: Tag,
    ) {
        self.tag = tag
    }

    var body: some View {
        HStack {
            Label(tag.name, systemImage: tag.kind.icon)
            Spacer(minLength: 8)
        }
        .contentShape(Rectangle())
        .tag(SidebarItem.tag(tag))
        .contextMenu {
            Button {
                actions?.editTag(tag)
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                actions?.deleteTag(tag)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
