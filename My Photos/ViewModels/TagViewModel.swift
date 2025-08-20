import SwiftUI
import SwiftData

enum TagEditorMode: Identifiable {
    case create
    case edit(Tag)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let tag): return "edit-\(tag.persistentModelID)"
        }
    }
    var tag: Tag? {
        if case let .edit(tag) = self { return tag }
        return nil
    }
}

@MainActor
final class TagViewModel: ObservableObject {
    @Published private var modelContext: ModelContext?
    
    @Published var tagEditorVisible: Bool = false
    @Published var folderSelectorVisible: Bool = false
    @Published var deleteTagAlertVisible: Bool = false
    @Published var notificationVisible: Bool = false
    
    @Published var notificationMessage: String = ""
    @Published var tagEditorMode: TagEditorMode? = nil
    @Published var selectedTag: Tag? = nil
    @Published var selectedItem: SidebarItem? = nil
    
    func setModelContext(_ modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func showTagEditor() {
        if let selectedTag {
            withAnimation {
                tagEditorVisible = true
                tagEditorMode = .edit(selectedTag)
            }
        } else {
            showNotification("Select a tag first.")
        }
    }
    func dismissTagEditor() {
        withAnimation {
            tagEditorVisible = false
            tagEditorMode = nil
        }
    }

    func showTagCreator() {
        print("Showing the tag creator...")

        withAnimation {
            tagEditorVisible = true
            tagEditorMode = .create
        }
    }
    func dismissTagCreator() {
        withAnimation {
            tagEditorVisible = false
            tagEditorMode = nil
        }
    }

    func showFolderSelector() {
        withAnimation {
            folderSelectorVisible = true
        }
    }
    func dismissFolderSelector() {
        withAnimation {
            folderSelectorVisible = false
        }
    }

    func showDeleteTagAlert() {
        if selectedTag != nil {
            withAnimation {
                deleteTagAlertVisible = true
            }
        } else {
            showNotification("Select a tag first.")
        }
    }
    func dismissDeleteTagAlert() {
        withAnimation {
            deleteTagAlertVisible = false
        }
    }

    func showNotification(_ message: String) {
        withAnimation {
            notificationMessage = message
            notificationVisible = true
        }
    }
    func dismissNotification() {
        withAnimation {
            notificationMessage = ""
            notificationVisible = false
        }
    }

    func selectItem(_ item: SidebarItem?) {
        withAnimation {
            selectedItem = item
        }
    }
    func selectTag(_ tag: Tag?) {
        withAnimation {
            selectedTag = tag
        }
    }

    func importFolder(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let folder = urls.first else { return }
            showNotification("Imported \(folder.lastPathComponent)")

        case .failure(let error):
            showNotification("Failed to import: \(error.localizedDescription)")
        }
    }

    // TODO: should I use selectedTag here too?
    func saveTag(original: Tag?, name: String, kind: TagKind) {
        if let original {
            original.name = name
            original.kind = kind
        } else {
            modelContext?.insert(Tag(name: name, kind: kind))
        }

        dismissTagEditor()
    }

    func deleteSelectedTag() {
        guard let tag = selectedTag else { return }

        modelContext?.delete(tag)
        dismissDeleteTagAlert()
        
        selectTag(nil)
        selectItem(nil)
    }
}
