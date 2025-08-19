import SwiftUI

struct LibraryActions {
    var importFolder: () -> Void
    var createTag: () -> Void
    var editTag: (Tag) -> Void
    var deleteTag: (Tag) -> Void
}

struct SelectedTagKey: FocusedValueKey { typealias Value = Tag? }
struct LibraryActionsKey: FocusedValueKey { typealias Value = LibraryActions }

extension FocusedValues {
    var selectedTag: Tag? {
        get { self[SelectedTagKey.self] ?? nil }
        set { self[SelectedTagKey.self] = newValue }
    }
    var libraryActions: LibraryActions? {
        get { self[LibraryActionsKey.self] }
        set { self[LibraryActionsKey.self] = newValue }
    }
}
struct LibraryCommands: Commands {
    @FocusedValue(\.selectedTag) private var selectedTag
    @FocusedValue(\.libraryActions) private var actions

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") { actions?.importFolder() }
                .keyboardShortcut("I", modifiers: [.command, .shift])
                .disabled(actions == nil)

            Button("Create Tag…") { actions?.createTag() }
                .keyboardShortcut("T", modifiers: [.command, .shift])
                .disabled(actions == nil)

            Button("Edit Tag…") {
                if let selectedTag { actions?.editTag(selectedTag) }
            }
            .keyboardShortcut("E", modifiers: [.command, .shift])
            .disabled(selectedTag == nil || actions == nil)

            Button("Delete Tag", role: .destructive) {
                if let selectedTag { actions?.deleteTag(selectedTag) }
            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
            .disabled(selectedTag == nil || actions == nil)
        }
    }
}
