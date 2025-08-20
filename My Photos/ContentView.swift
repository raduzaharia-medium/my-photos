import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]
    @ObservedObject private var sidebarState: SidebarState

    init(_ sidebarState: SidebarState) {
        self.sidebarState = sidebarState
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $sidebarState.selectedItem,
            )
            .sidebarWiring(sidebarState)
        } detail: {
            DetailView(sidebarState.selectedItem)
        }
        .onAppear {
            sidebarState.setModelContext(modelContext)
        }
        .toast(
            isPresented: $sidebarState.notificationVisible,
            message: sidebarState.notificationMessage
        )
    }
}
