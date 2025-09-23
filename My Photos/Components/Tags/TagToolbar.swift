import SwiftUI

struct TagToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem {
            Button {
                AppIntents.requestCreateTag()
            } label: {
                Label("New Tag", systemImage: "plus")
            }
        }
    }
}
