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
                    AppIntents.requestEditTag(selection.selectedTags.first!)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }

            if selection.canDeleteSelection {
                Button(role: .destructive) {
                    AppIntents.requestDeleteTag(selection.selectedTags.first!)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } else if selection.canDeleteManySelection {
                Button(role: .destructive) {
                    AppIntents.requestDeleteTags(selection.selectedTags)
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
