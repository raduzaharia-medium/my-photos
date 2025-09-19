import SwiftData
import SwiftUI

struct LibraryCommands: Commands {
    @ObservedObject var tagSelectionModel: TagSelectionModel

    init(_ tagSelectionModel: TagSelectionModel) {
        self._tagSelectionModel = ObservedObject(
            wrappedValue: tagSelectionModel
        )
    }

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") { AppIntents.requestImportPhotos() }
                .keyboardShortcut("I", modifiers: [.command, .shift])

            Divider()

            Button("Create Tag…") { AppIntents.requestCreateTag() }
                .keyboardShortcut("T", modifiers: [.command, .shift])

            Button("Edit Tag…") {
                guard let tag = tagSelectionModel.singleTag else { return }
                AppIntents.requestEditTag(tag)
            }
            .keyboardShortcut("E", modifiers: [.command, .shift])
            .disabled(tagSelectionModel.singleTag == nil)

            Button("Delete Tag", role: .destructive) {
                guard let tag = tagSelectionModel.singleTag else { return }
                AppIntents.requestDeleteTag(tag)
            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
            .disabled(tagSelectionModel.singleTag == nil)
        }
    }
}
