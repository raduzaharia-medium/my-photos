import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]
    
    @StateObject private var libraryController = LibraryController()
    @State private var sidebarSelection: SidebarItem? = nil
    
    var selectedTag: Tag? {
        if case .tag(let tag) = sidebarSelection { return tag }
        return nil
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $sidebarSelection,
            )
        } detail: {
            DetailView(sidebarSelection)
        }
        .libraryWiring(libraryController, selection: $sidebarSelection)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Tag.self, inMemory: true)
}
