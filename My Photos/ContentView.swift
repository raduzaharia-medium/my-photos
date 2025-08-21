import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    @ObservedObject private var tagViewModel: TagViewModel
    @ObservedObject private var notificationService: NotificationService
    @ObservedObject private var alertService: AlertService

    @State private var selection: SidebarItem? = nil

    init(
        tagViewModel: TagViewModel,
        notificationService: NotificationService,
        alertService: AlertService
    ) {
        self.tagViewModel = tagViewModel
        self.notificationService = notificationService
        self.alertService = alertService
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $selection,
                tagViewModel: tagViewModel
            )
            .sidebarWiring(tagViewModel: tagViewModel)
        } detail: {
            DetailView(tagViewModel.selectedItem)
        }
        .onAppear {
            tagViewModel.setModelContext(modelContext)
            tagViewModel.setNotifier(notificationService)
            tagViewModel.setAlerter(alertService)
        }
        .onChange(of: selection) {
            tagViewModel.selectItem(selection)
        }
        .toast(
            isPresented: $notificationService.isVisible,
            message: notificationService.message
        )
        .alert(
            alertService.title,
            isPresented: $alertService.isVisible
        ) {
            Button(alertService.actionLabel, role: .destructive) {
                alertService.action()
            }
            Button(alertService.cancelLabel, role: .cancel) {
                alertService.cancel()
            }
        } message: {
            Text(alertService.message)
        }
        .fileImporter(
            isPresented: $tagViewModel.folderSelectorVisible,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false,
            onCompletion: tagViewModel.importFolder
        )
    }
}
