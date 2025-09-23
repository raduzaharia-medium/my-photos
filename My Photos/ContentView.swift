import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(PresentationState.self) private var presentationState
    @Environment(\.modelContext) private var context

    @StateObject private var modalPresenter = ModalService()
    @StateObject private var alerter = AlertService()
    @StateObject private var fileImporter = FileImportService()
    @StateObject private var notifier = NotificationService()

    private var tagStore: TagStore { TagStore(context: context) }

    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    var body: some View {
        NavigationSplitView {
            SidebarView(Filter.allCases, tags)
        } detail: {
            DetailView()
        }
        .notification(
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
        .setupHandlers(
            modalPresenter: modalPresenter,
            notifier: notifier,
            fileImporter: fileImporter,
            alerter: alerter,
            tagStore: tagStore
        )
        .setupPresentationModeHandlers(presentationState: presentationState)
    }
}
