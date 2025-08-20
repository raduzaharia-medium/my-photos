import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]
    @ObservedObject private var tagViewModel: TagViewModel
    @ObservedObject private var notificationViewModel: NotificationViewModel

    init(_ tagViewModel: TagViewModel, _ notificationViewModel: NotificationViewModel) {
        self.tagViewModel = tagViewModel
        self.notificationViewModel = notificationViewModel
    }

    var body: some View {
        let selection = Binding<SidebarItem?>(
            get: { tagViewModel.selectedItem },
            set: { tagViewModel.selectItem($0) }
        )

        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                selection,
            )
            .sidebarWiring(tagViewModel)
        } detail: {
            DetailView(tagViewModel.selectedItem)
        }
        .onAppear {
            tagViewModel.setModelContext(modelContext)
            tagViewModel.setNotifier(notificationViewModel)
        }
        .toast(
            isPresented: $notificationViewModel.isVisible,
            message: notificationViewModel.message
        )
        .fileImporter(
            isPresented: $tagViewModel.folderSelectorVisible,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false,
            onCompletion: tagViewModel.importFolder
        )
    }
}
