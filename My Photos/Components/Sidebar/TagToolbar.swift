import SwiftUI

struct TagToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem {
            Menu {
                Button {
                    AppIntents.requestCreateTag()
                } label: {
                    Label("New Tag", systemImage: "plus")
                }

                Button {
                    AlbumIntents.requestCreate()
                } label: {
                    Label("Album", systemImage: "plus")
                }
            } label: {
                Label("New Tag", systemImage: "plus")
            }
        }
    }
}
