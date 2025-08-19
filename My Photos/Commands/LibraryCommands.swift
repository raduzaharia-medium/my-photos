import SwiftUI

struct LibraryActions {
    var importFolder: () -> Void
    var createTag: () -> Void
    var editTag: (Tag) -> Void
    var deleteTag: (Tag) -> Void
}

struct LibraryActionsKey: EnvironmentKey {
    static let defaultValue = LibraryActions(
        importFolder: {},
        createTag: {},
        editTag: { _ in },
        deleteTag: { _ in }
    )
}
struct SelectedTagKey: EnvironmentKey {
    static let defaultValue: Tag? = nil
}

extension EnvironmentValues {
    var selectedTag: Tag? {
        get { self[SelectedTagKey.self] ?? nil }
        set { self[SelectedTagKey.self] = newValue }
    }
    var libraryActions: LibraryActions {
        get { self[LibraryActionsKey.self] }
        set { self[LibraryActionsKey.self] = newValue }
    }
}
struct LibraryCommands: Commands {
    @Environment(\.selectedTag) private var selectedTag
    @Environment(\.libraryActions) private var actions

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") { actions.importFolder() }
                .keyboardShortcut("I", modifiers: [.command, .shift])

            Divider()
            
            Button("Create Tag…") { actions.createTag() }
                .keyboardShortcut("T", modifiers: [.command, .shift])

            Button("Edit Tag…") {
                if let selectedTag { actions.editTag(selectedTag) }
            }
            .keyboardShortcut("E", modifiers: [.command, .shift])
            .disabled(selectedTag == nil)

            Button("Delete Tag", role: .destructive) {
                if let selectedTag { actions.deleteTag(selectedTag) }
            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
            .disabled(selectedTag == nil)
        }
    }
}
