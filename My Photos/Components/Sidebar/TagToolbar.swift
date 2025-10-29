import SwiftUI

struct TagToolbar: ToolbarContent {
    #if os(iOS)
    var placement: ToolbarItemPlacement = .topBarTrailing
    #else
    var placement: ToolbarItemPlacement = .automatic
    #endif
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Menu {
                Button {
                    AlbumIntents.requestCreate()
                } label: {
                    Label("New Album", systemImage: Album.icon)
                }

                Button {
                    PersonIntents.requestCreate()
                } label: {
                    Label("New Person", systemImage: Person.icon)
                }

                Button {
                    EventIntents.requestCreate()
                } label: {
                    Label("New Event", systemImage: Event.icon)
                }

                Button {
                    TagIntents.requestCreate()
                } label: {
                    Label("New Tag", systemImage: Tag.icon)
                }
            } label: {
                Label("New", systemImage: "plus")
            }
        }
    }
}
