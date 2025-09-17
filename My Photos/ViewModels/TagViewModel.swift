import SwiftData
import SwiftUI

@MainActor
final class TagViewModel: ObservableObject {
    private var modelContext: ModelContext?
    private var services: Services?
    
    @Published var selectedItem: Set<SidebarItem> = []

    var selectedTag: Tag? {
        guard let item = selectedItem.first else { return nil }
        
        if case let .tag(t) = item { return t }
        return nil
    }

    func setModelContext(_ val: ModelContext) { self.modelContext = val }
    func setServices(_ val: Services) { self.services = val }
    
    func selectItem(_ selection: Set<SidebarItem>) { self.selectedItem = selection }

    func importFolder() {
        services?.fileImporter.pickSingleFolder { [weak self] result in
            switch result {
            case .success(let urls):
                guard let folder = urls.first else { return }
                self?.services?.notifier.show(
                    "Imported \(folder.lastPathComponent)",
                    .success
                )

            case .failure(let error):
                self?.services?.notifier.show(
                    "Failed to import: \(error.localizedDescription)",
                    .error
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
}
