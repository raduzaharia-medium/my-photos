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

            if let single = tagSelectionModel.singleTag {
                Button("Delete Tag", role: .destructive) {
                    AppIntents.requestDeleteTag(single)
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }

            if tagSelectionModel.allTags.count > 1 {
                let count = tagSelectionModel.allTags.count
                Button("Delete \(count) Tags", role: .destructive) {
                    AppIntents.requestDeleteTags(tagSelectionModel.allTags)
                }
                .keyboardShortcut("D", modifiers: [.command, .shift])
            }
        }
    }
}
