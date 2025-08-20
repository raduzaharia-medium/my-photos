import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]
    @ObservedObject private var tagViewModel: TagViewModel

    init(_ tagViewModel: TagViewModel) {
        self.tagViewModel = tagViewModel
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $tagViewModel.selectedItem,
            )
            .sidebarWiring(tagViewModel)
        } detail: {
            DetailView(tagViewModel.selectedItem)
        }
        .onAppear {
            tagViewModel.setModelContext(modelContext)
        }
        .toast(
            isPresented: $tagViewModel.notificationVisible,
            message: tagViewModel.notificationMessage
        )
        .fileImporter(
            isPresented: $tagViewModel.folderSelectorVisible,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false,
            onCompletion: tagViewModel.importFolder
        )
    }
}
