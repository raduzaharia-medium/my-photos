import SwiftUI

struct TagContextMenu: View {
    var selection: Set<SidebarItem>

    init(_ selection: Set<SidebarItem>) {
        self.selection = selection
    }

    var body: some View {
        if !selection.canEditOrDeleteSelection {
            EmptyView()
        } else {
            if selection.canEditSelection {
                Button {
                    TagIntents.requestEdit(selection.selectedTags.first!)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }

            if selection.canDeleteSelection {
                Button(role: .destructive) {
                    TagIntents.requestDelete(selection.selectedTags.first!)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } else if selection.canDeleteManySelection {
                Button(role: .destructive) {
                    TagIntents.requestDelete(selection.selectedTags)
                } label: {
                    Label(
                        "Delete \(selection.selectedTags.count) Tags",
                        systemImage: "trash"
                    )
                }
            }
        }
    }
}
