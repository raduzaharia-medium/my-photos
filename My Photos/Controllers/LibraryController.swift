import SwiftData
import SwiftUI
import UniformTypeIdentifiers

enum TagEditor: Identifiable {
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
final class LibraryController: ObservableObject {
    @Published var showImportFolder = false
    @Published var showToast = false
    @Published var toastMessage = ""
    
    @Published var editor: TagEditor?
    @Published var pendingDelete: Tag?

    private var modelContext: ModelContext!

    lazy var actions = LibraryActions(
        importFolder: { [weak self] in self?.showImportFolder = true },
        createTag: { [weak self] in self?.editor = .create },
        editTag: { [weak self] tag in self?.editor = .edit(tag) },
        deleteTag: { [weak self] tag in self?.pendingDelete = tag }
    )

    func setContext(_ context: ModelContext) {
        if modelContext == nil { modelContext = context }
    }

    func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let folder = urls.first else { return }

            toastMessage = "Imported \(folder.lastPathComponent)"
            withAnimation { showToast = true }

        case .failure(let error):
            toastMessage = "Failed to import: \(error.localizedDescription)"
            withAnimation { showToast = true }
        }
    }

    func performSave(original: Tag?, name: String, kind: TagKind) {
        withAnimation {
            if let original {
                original.name = name
                original.kind = kind
            } else {
                modelContext.insert(Tag(name: name, kind: kind))
            }

            editor = nil
        }
    }

    func performDelete() {
        guard let tag = pendingDelete else { return }

        withAnimation {
            modelContext.delete(tag)
            pendingDelete = nil
        }
    }
}
