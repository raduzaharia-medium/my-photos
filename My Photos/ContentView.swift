import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    @ObservedObject private var tagViewModel: TagViewModel
    @ObservedObject private var notificationViewModel: NotificationViewModel
    @ObservedObject private var alertViewModel: AlertViewModel

    @State private var selection: SidebarItem? = nil

    init(
        tagViewModel: TagViewModel,
        notificationViewModel: NotificationViewModel,
        alertViewModel: AlertViewModel
    ) {
        self.tagViewModel = tagViewModel
        self.notificationViewModel = notificationViewModel
        self.alertViewModel = alertViewModel
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $selection,
            )
            .sidebarWiring(
                tagViewModel: tagViewModel,
                alertViewModel: alertViewModel
            )
        } detail: {
            DetailView(tagViewModel.selectedItem)
        }
        .onAppear {
            tagViewModel.setModelContext(modelContext)
            tagViewModel.setNotifier(notificationViewModel)
            tagViewModel.setAlerter(alertViewModel)
        }
        .onChange(of: selection) {
            tagViewModel.selectItem(selection)
        }
        .toast(
            isPresented: $notificationViewModel.isVisible,
            message: notificationViewModel.message
        )
        .alert(
            alertViewModel.title,
            isPresented: $alertViewModel.isVisible
        ) {
            Button(alertViewModel.actionLabel, role: .destructive) {
                alertViewModel.action()
            }
            Button(alertViewModel.cancelLabel, role: .cancel) {
                alertViewModel.cancel()
            }
        } message: {
            Text(alertViewModel.message)
        }
        .fileImporter(
            isPresented: $tagViewModel.folderSelectorVisible,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false,
            onCompletion: tagViewModel.importFolder
        )
    }
}
