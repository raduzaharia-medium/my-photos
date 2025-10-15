import SwiftUI

struct TagToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem {
            Menu {
                Button {
                    AppIntents.requestCreateTag()
                } label: {
                    Label("New Place", systemImage: Place.icon)
                }

                Button {
                    AlbumIntents.requestCreate()
                } label: {
                    Label("New Album", systemImage: Album.icon)
                }

                Button {
                    AppIntents.requestCreateTag()
                } label: {
                    Label("New Person", systemImage: Person.icon)
                }

                Button {
                    AppIntents.requestCreateTag()
                } label: {
                    Label("New Event", systemImage: Event.icon)
                }

                Button {
                    AppIntents.requestCreateTag()
                } label: {
                    Label("New Tag", systemImage: Tag.icon)
                }
            } label: {
                Label("New", systemImage: "plus")
            }
        }
    }
}
