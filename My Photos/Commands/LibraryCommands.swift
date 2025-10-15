import SwiftData
import SwiftUI

struct LibraryCommands: Commands {
    @Binding var presentationState: PresentationState

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") { AppIntents.requestImportPhotos() }
                .keyboardShortcut("I", modifiers: [.command, .shift])

            Divider()

            Button("Create Tag…") { TagIntents.requestCreate() }
                .keyboardShortcut("T", modifiers: [.command, .shift])

            Button("Edit Tag…") {
                guard presentationState.photoFilter.count == 1,
                    case .tag(let tag) = presentationState.photoFilter.first
                else {
                    return
                }

                TagIntents.requestEdit(tag)
            }
            .keyboardShortcut("E", modifiers: [.command, .shift])
            .disabled(!presentationState.canEditSelection)

            if presentationState.canDeleteSelection {
                Button("Delete Tag", role: .destructive) {
                    TagIntents.requestDelete(presentationState.selectedTags.first!)
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }

            if presentationState.canDeleteManySelection {
                Button(
                    "Delete \(presentationState.selectedTags.count) Tags",
                    role: .destructive
                ) {
                    TagIntents.requestDelete(presentationState.selectedTags)
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }

            Divider()

            Button("Previous Photo") { AppIntents.navigateToPreviousPhoto() }
                .keyboardShortcut("<", modifiers: [])

            Button("Next Photo") { AppIntents.navigateToNextPhoto() }
                .keyboardShortcut(">", modifiers: [])

            Divider()

            if presentationState.presentationMode == .grid {
                Button("Switch to map view") {
                    AppIntents.togglePresentationMode()
                }
                .keyboardShortcut("M", modifiers: [.command])
            } else if presentationState.presentationMode == .map {
                Button("Switch to grid view") {
                    AppIntents.togglePresentationMode()
                }
                .keyboardShortcut("G", modifiers: [.command])
            }
            
            Button("Switch selection mode") {
                AppIntents.toggleSelectionMode()
            }
        }
    }
}
