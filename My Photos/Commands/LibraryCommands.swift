import SwiftUI

// TODO: Split in TagCommands and LibraryCommands
struct LibraryCommands: Commands {
    @ObservedObject var tagViewModel: TagViewModel

    init(_ tagViewModel: TagViewModel) {
        self._tagViewModel = ObservedObject(wrappedValue: tagViewModel)
    }

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") { tagViewModel.showFolderSelector() }
                .keyboardShortcut("I", modifiers: [.command, .shift])

            Divider()

            Button("Create Tag…") { tagViewModel.showTagCreator() }
                .keyboardShortcut("T", modifiers: [.command, .shift])

            Button("Edit Tag…") { tagViewModel.showTagEditor() }
                .keyboardShortcut("E", modifiers: [.command, .shift])
                .disabled(tagViewModel.selectedTag == nil)

            Button("Delete Tag", role: .destructive) {
                tagViewModel.deleteSelectedTag()
            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
            .disabled(tagViewModel.selectedTag == nil)
        }
    }
}
