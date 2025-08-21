import SwiftData
import SwiftUI

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
    private var modelContext: ModelContext?
    private var notifier: Notifier?
    private var alerter: Alerter?
    private var fileImporter: FileImporter?

    @Published var tagEditorVisible: Bool = false
    @Published var tagEditorMode: TagEditorMode? = nil
    @Published var selectedItem: SidebarItem? = nil

    var selectedTag: Tag? {
        if case let .tag(t) = selectedItem { return t }
        return nil
    }

    func setModelContext(_ modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    func setNotifier(_ notifier: Notifier) {
        self.notifier = notifier
    }
    func setAlerter(_ alerter: Alerter) {
        self.alerter = alerter
    }
    func setFileImporter(_ fileImporter: FileImporter) {
        self.fileImporter = fileImporter
    }

    func showTagEditor() {
        if let selectedTag {
            withAnimation {
                tagEditorVisible = true
                tagEditorMode = .edit(selectedTag)
            }
        } else {
            notifier?.show("Select a tag first.")
        }
    }
    func dismissTagEditor() {
        withAnimation {
            tagEditorVisible = false
            tagEditorMode = nil
        }
    }

    func showTagCreator() {
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

    func selectItem(_ item: SidebarItem?) {
        withAnimation { self.selectedItem = item }
    }

    func importFolder() {
        fileImporter?.show { [weak self] result in
            switch result {
            case .success(let urls):
                guard let folder = urls.first else { return }
                self?.notifier?.show("Imported \(folder.lastPathComponent)")

            case .failure(let error):
                self?.notifier?.show(
                    "Failed to import: \(error.localizedDescription)"
                )
            }
        }
    }

    func saveTag(original: Tag?, name: String, kind: TagKind) {
        if let original {
            original.name = name
            original.kind = kind
        } else {
            modelContext?.insert(Tag(name: name, kind: kind))
        }

        dismissTagEditor()
    }

    func deleteTag(_ tag: Tag) {
        alerter?.show(
            "Delete \(tag.name)?",
            "Are you sure you want to delete this tag?",
            actionLabel: "Delete",
            onAction: { [weak self] in
                self?.modelContext?.delete(tag)
                self?.selectItem(nil)
            }
        )
    }

    func deleteSelectedTag() {
        guard let tag = selectedTag else { return }

        alerter?.show(
            "Delete \(tag.name)?",
            "Are you sure you want to delete this tag?",
            actionLabel: "Delete",
            onAction: { [weak self] in
                self?.modelContext?.delete(tag)
                self?.selectItem(nil)
            }
        )
    }
}
