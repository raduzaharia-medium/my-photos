import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    @ObservedObject private var tagViewModel: TagViewModel
    @ObservedObject private var notificationService: NotificationService
    @ObservedObject private var alertService: AlertService
    @ObservedObject private var fileImportService: FileImportService
    @ObservedObject private var modalPresenterService: ModalPresenterService

    @State private var selection: SidebarItem? = nil

    init(
        tagViewModel: TagViewModel,
        notificationService: NotificationService,
        alertService: AlertService,
        fileImportService: FileImportService,
        modalPresenterService: ModalPresenterService
    ) {
        self.tagViewModel = tagViewModel
        self.notificationService = notificationService
        self.alertService = alertService
        self.fileImportService = fileImportService
        self.modalPresenterService = modalPresenterService
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $selection,
                tagViewModel: tagViewModel
            )
        } detail: {
            DetailView(tagViewModel.selectedItem)
        }
        .onAppear {
            tagViewModel.setModelContext(modelContext)
            tagViewModel.setNotifier(notificationService)
            tagViewModel.setAlerter(alertService)
            tagViewModel.setFileImporter(fileImportService)
            tagViewModel.setModalPresenter(modalPresenterService)
        }
        .onChange(of: selection) {
            withAnimation { tagViewModel.selectItem(selection) }
        }
        .toast(
            isPresented: $notificationService.isVisible,
            message: notificationService.message,
            style: notificationService.style
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
        .sheet(
            item: $modalPresenterService.item,
            onDismiss: modalPresenterService.item?.onDismiss
        ) {
            item in item.content
        }
        .fileImporter(
            isPresented: $fileImportService.isVisible,
            allowedContentTypes: fileImportService.allowedContentTypes,
            allowsMultipleSelection: fileImportService.multipleSelection,
            onCompletion: fileImportService.action
        )
    }
}
