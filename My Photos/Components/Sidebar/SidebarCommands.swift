import SwiftUI

// TODO: Split in TagCommands and LibraryCommands
struct SidebarCommands: Commands {
    @ObservedObject var sidebarState: SidebarState

    init(_ sidebarState: SidebarState) {
        self._sidebarState = ObservedObject(wrappedValue: sidebarState)
    }

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") { sidebarState.showFolderSelector() }
                .keyboardShortcut("I", modifiers: [.command, .shift])

            Divider()

            Button("Create Tag…") { sidebarState.showTagCreator() }
                .keyboardShortcut("T", modifiers: [.command, .shift])

            Button("Edit Tag…") { sidebarState.showTagEditor() }
                .keyboardShortcut("E", modifiers: [.command, .shift])
                .disabled(sidebarState.selectedTag == nil)

            Button("Delete Tag", role: .destructive) {
                sidebarState.showDeleteTagAlert()
            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
            .disabled(sidebarState.selectedTag == nil)
        }
    }
}
