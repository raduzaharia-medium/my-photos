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

//            Button("Edit Tag…") {
//                guard presentationState.photoFilter.count == 1,
//                    case .tag(let tag) = presentationState.photoFilter.first
//                else {
//                    return
//                }
//
//                TagIntents.requestEdit(tag)
//            }
//            .keyboardShortcut("E", modifiers: [.command, .shift])
//            .disabled(!presentationState.canEditSelection)
//
//            if presentationState.canDeleteSelection {
//                Button("Delete Tag", role: .destructive) {
//                    TagIntents.requestDelete(presentationState.selectedTags.first!)
//                }
//                .keyboardShortcut("D", modifiers: [.command, .shift])
//            }
//
//            if presentationState.canDeleteManySelection {
//                Button(
//                    "Delete \(presentationState.selectedTags.count) Tags",
//                    role: .destructive
//                ) {
//                    TagIntents.requestDelete(presentationState.selectedTags)
//                }
//                .keyboardShortcut("D", modifiers: [.command, .shift])
//            }

            Divider()
            
            Button("Switch selection mode") {
                PhotoIntents.toggleSelectionMode()
            }
        }
    }
}
