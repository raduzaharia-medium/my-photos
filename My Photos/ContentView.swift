import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]
    @State private var sidebarSelection: SidebarItem? = nil
    @ObservedObject private var sidebarState: SidebarState
    
    var selectedTag: Tag? {
        if case .tag(let tag) = sidebarSelection { return tag }
        return nil
    }
    
    init(_ sidebarState: SidebarState) {
        self.sidebarState = sidebarState
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $sidebarSelection,
            )
            .sidebarWiring(sidebarState)
        } detail: {
            DetailView(sidebarSelection)
        }
        .onAppear {
            sidebarState.setModelContext(modelContext)
        }
    }
}
