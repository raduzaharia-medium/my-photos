import SwiftUI

struct NewTagButton: View {
    var body: some View {
        Button {
            AppIntents.requestCreateTag()
        } label: {
            Label("New Tag", systemImage: "plus")
        }
    }
}

struct TagToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem {
            NewTagButton()
        }
    }
}
