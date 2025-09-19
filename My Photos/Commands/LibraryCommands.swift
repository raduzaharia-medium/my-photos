import SwiftData
import SwiftUI

struct LibraryCommands: Commands {
    @FocusedBinding(\.sidebarSelection) var selection

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") { AppIntents.requestImportPhotos() }
                .keyboardShortcut("I", modifiers: [.command, .shift])

            Divider()

            Button("Create Tag…") { AppIntents.requestCreateTag() }
                .keyboardShortcut("T", modifiers: [.command, .shift])

            Button("Edit Tag…") {
                guard selection?.count == 1,
                    case .tag(let tag) = selection?.first
                else {
                    return
                }

                AppIntents.requestEditTag(tag)
            }
            .keyboardShortcut("E", modifiers: [.command, .shift])
            .disabled(selection?.allTags.isEmpty ?? true)

            if let tag = selection?.singleTag {
                Button("Delete Tag", role: .destructive) {
                    AppIntents.requestDeleteTag(tag)
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }

            if let selectedTags = selection?.allTags, selectedTags.count > 1 {
                Button("Delete \(selectedTags.count) Tags", role: .destructive) {
                    AppIntents.requestDeleteTags(selectedTags)
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }
        }
    }
}
