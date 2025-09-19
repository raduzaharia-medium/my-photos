import SwiftUI

struct TagContextMenu: View {
    var selection: Set<SidebarItem>

    init(_ selection: Set<SidebarItem>) {
        self.selection = selection
    }

    var body: some View {
        if let tag = selection.singleTag {
            Button {
                AppIntents.requestEditTag(tag)
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                AppIntents.requestDeleteTag(tag)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } else if !selection.allTags.isEmpty {
            Button(role: .destructive) {
                AppIntents.requestDeleteTags(selection.allTags)
            } label: {
                Label("Delete \(selection.allTags.count) Tags", systemImage: "trash")
            }
        }
    }
}
