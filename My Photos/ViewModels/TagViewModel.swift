import SwiftData
import SwiftUI

@MainActor
final class TagViewModel: ObservableObject {
    private var modelContext: ModelContext?
    private var notifier: Notifier?
    private var alerter: Alerter?
    private var fileImporter: FileImporter?
    private var modalPresenter: ModalPresenter?

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
    func setModalPresenter(_ modalPresenter: ModalPresenter) {
        self.modalPresenter = modalPresenter
    }

    func selectItem(_ item: SidebarItem?) {
        withAnimation { self.selectedItem = item }
    }

    func createTag() {
        modalPresenter?.show(onDismiss: { [weak self] in
            self?.modalPresenter?.dismiss()
        }) {
            TagEditorSheet(
                nil,
                onSave: { [weak self] original, name, kind in
                    self?.saveTag(original: original, name: name, kind: kind)
                    self?.modalPresenter?.dismiss()
                },
                onCancel: { [weak self] in self?.modalPresenter?.dismiss() }
            )
        }
    }

    func editTag(_ tag: Tag) {
        modalPresenter?.show(onDismiss: { [weak self] in
            self?.modalPresenter?.dismiss()
        }) {
            TagEditorSheet(
                tag,
                onSave: { [weak self] original, name, kind in
                    self?.saveTag(original: original, name: name, kind: kind)
                    self?.modalPresenter?.dismiss()
                },
                onCancel: { [weak self] in self?.modalPresenter?.dismiss() }
            )
        }
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
