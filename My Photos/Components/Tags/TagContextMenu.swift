import SwiftUI

struct TagContextMenu: View {
    var selection: Set<SidebarItem>

    init(_ selection: Set<SidebarItem>) {
        self.selection = selection
    }

    var body: some View {
        if let tag = singleTag(from: selection) {
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
        } else if let tags = allTags(from: selection), !tags.isEmpty {
            Button(role: .destructive) {
                AppIntents.requestDeleteTags(tags)
            } label: {
                Label("Delete \(tags.count) Tags", systemImage: "trash")
            }
        }
    }

    private func singleTag(from items: Set<SidebarItem>) -> Tag? {
        guard items.count == 1, case .tag(let t) = items.first else {
            return nil
        }

        return t
    }

    private func allTags(from items: Set<SidebarItem>) -> [Tag]? {
        let tags: [Tag] = items.compactMap { item in
            if case .tag(let t) = item { return t }
            return nil
        }
        return tags
    }
}
