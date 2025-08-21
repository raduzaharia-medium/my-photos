import SwiftUI

struct TagContextMenu: View {
    @ObservedObject var tagViewModel: TagViewModel

    var selection: Set<SidebarItem>

    init(_ selection: Set<SidebarItem>, _ tagViewModel: TagViewModel) {
        self.selection = selection
        self.tagViewModel = tagViewModel
    }

    var body: some View {
        if let tag = singleTag(from: selection) {
            Button {
                tagViewModel.selectItem(.tag(tag))
                tagViewModel.showTagEditor()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive) {
                tagViewModel.deleteTag(tag)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func singleTag(from items: Set<SidebarItem>) -> Tag? {
        guard items.count == 1, case let .tag(t) = items.first else {
            return nil
        }

        return t
    }
}
