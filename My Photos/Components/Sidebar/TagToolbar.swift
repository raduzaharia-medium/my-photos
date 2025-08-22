import SwiftUI

struct NewTagButton: View {
    @ObservedObject var tagViewModel: TagViewModel

    init(_ tagViewModel: TagViewModel) {
        self.tagViewModel = tagViewModel
    }

    var body: some View {
        Button {
            tagViewModel.createTag()
        } label: {
            Label("New Tag", systemImage: "plus")
        }
    }
}

struct TagToolbar: ToolbarContent {
    @ObservedObject var tagViewModel: TagViewModel

    var body: some ToolbarContent {
        ToolbarItem {
            NewTagButton(tagViewModel)
        }
    }
}
