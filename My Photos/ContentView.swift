import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    @ObservedObject private var tagViewModel: TagViewModel
    @ObservedObject private var notificationService: NotificationService
    @ObservedObject private var alertService: AlertService
    @ObservedObject private var fileImportService: FileImportService

    @State private var selection: SidebarItem? = nil

    init(
        tagViewModel: TagViewModel,
        notificationService: NotificationService,
        alertService: AlertService,
        fileImportService: FileImportService
    ) {
        self.tagViewModel = tagViewModel
        self.notificationService = notificationService
        self.alertService = alertService
        self.fileImportService = fileImportService
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
            tagViewModel.setFileImporter(fileImportService)
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
            isPresented: $fileImportService.isVisible,
            allowedContentTypes: fileImportService.allowedContentTypes,
            allowsMultipleSelection: fileImportService.multipleSelection,
            onCompletion: fileImportService.action
        )
    }
}
