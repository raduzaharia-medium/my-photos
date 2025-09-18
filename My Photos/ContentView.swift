import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var modalPresenter: ModalService
    @EnvironmentObject private var alerter: AlertService
    @EnvironmentObject private var fileImporter: FileImportService
    @EnvironmentObject private var notifier: NotificationService
    @EnvironmentObject private var tagSelectionModel: TagSelectionModel

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    var body: some View {
        NavigationSplitView {
            SidebarView(
                Filter.allCases,
                tags,
                $tagSelectionModel.selection
            )
        } detail: {
            DetailView(tagSelectionModel.selection)
        }
        .toast(
            isPresented: $notifier.isVisible,
            message: notifier.message,
            style: notifier.style
        )
        .sheet(
            item: $modalPresenter.item,
            onDismiss: {
                modalPresenter.item?.onDismiss?()
            }
        ) { item in
            item.content
        }
        .alert(
            alerter.title,
            isPresented: $alerter.isVisible
        ) {
            Button(alerter.actionLabel, role: .destructive) {
                alerter.action()
            }
            Button(alerter.cancelLabel, role: .cancel) {
                alerter.cancel()
            }
        } message: {
            Text(alerter.message)
        }
        .fileImporter(
            isPresented: $fileImporter.isVisible,
            allowedContentTypes: fileImporter.allowedContentTypes,
            allowsMultipleSelection: fileImporter.multipleSelection,
            onCompletion: fileImporter.action
        )
    }
}
