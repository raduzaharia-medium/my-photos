import SwiftData
import SwiftUI

struct LibraryCommands: Commands {
    @Binding var presentationState: PresentationState

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") { PhotoIntents.requestImport() }
                .keyboardShortcut("I", modifiers: [.command, .shift])

            Divider()

            Menu("Create") {
                Button("Album…") { AlbumIntents.requestCreate() }
                    .keyboardShortcut("A", modifiers: [.command, .shift])
                Button("Person…") { PersonIntents.requestCreate() }
                    .keyboardShortcut("P", modifiers: [.command, .shift])
                Button("Event…") { EventIntents.requestCreate() }
                    .keyboardShortcut("E", modifiers: [.command, .shift])
                Button("Tag…") { TagIntents.requestCreate() }
                    .keyboardShortcut("T", modifiers: [.command, .shift])
            }

            if presentationState.photoFilter.count == 1 {
                let selection = presentationState.photoFilter.first

                if case .album(let album) = selection {
                    Button("Edit Album…") {
                        AlbumIntents.requestEdit(album)
                    }
                    Button("Delete Album…") {
                        AlbumIntents.requestDelete(album)
                    }
                }

                if case .person(let person) = selection {
                    Button("Edit Person…") {
                        PersonIntents.requestEdit(person)
                    }
                    Button("Delete Person…") {
                        PersonIntents.requestDelete(person)
                    }
                }

                if case .event(let event) = selection {
                    Button("Edit Event…") {
                        EventIntents.requestEdit(event)
                    }
                    Button("Delete Event…") {
                        EventIntents.requestDelete(event)
                    }
                }

                if case .tag(let tag) = selection {
                    Button("Edit Tag…") {
                        TagIntents.requestEdit(tag)
                    }
                    Button("Delete Tag…") {
                        TagIntents.requestDelete(tag)
                    }
                }
            } else if presentationState.photoFilter.count > 1 {
                Button("Delete Items…") {
                    FilterIntents.requestDelete(
                        Array(presentationState.photoFilter)
                    )
                }
            }
        }
    }
}
