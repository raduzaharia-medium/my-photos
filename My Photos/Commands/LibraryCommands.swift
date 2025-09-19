import SwiftData
import SwiftUI

struct LibraryCommands: Commands {
    @FocusedBinding(\.sidebarSelection) var selection

    var body: some Commands {
        let currentSelection = selection ?? []
        let selectedTags: [Tag] = currentSelection.compactMap {
            if case .tag(let t) = $0 { t } else { nil }
        }
        let singleTag = selectedTags.count == 1 ? selectedTags.first : nil

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
            .disabled(selectedTags.isEmpty)

            if let tag = singleTag {
                Button("Delete Tag", role: .destructive) {
                    AppIntents.requestDeleteTag(tag)
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }

            if selectedTags.count > 1 {
                Button("Delete \(selectedTags.count) Tags", role: .destructive)
                {
                    AppIntents.requestDeleteTags(selectedTags)
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }
        }
    }
}
