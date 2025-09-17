import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var modalPresenter: ModalPresenterService
    @EnvironmentObject private var alerter: AlertService
    @Query(sort: \Tag.name, order: .forward) private var tags: [Tag]

    @ObservedObject private var tagViewModel: TagViewModel
    @ObservedObject private var services: Services

    @State private var selection: Set<SidebarItem> = []

    init(
        tagViewModel: TagViewModel,
        services: Services
    ) {
        self.tagViewModel = tagViewModel
        self.services = services
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
            tagViewModel.setServices(services)
        }
        .onChange(of: selection) {
            withAnimation { tagViewModel.selectItem(selection) }
        }
        .toast(
            isPresented: $services.notifier.isVisible,
            message: services.notifier.message,
            style: services.notifier.style
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
            isPresented: $services.fileImporter.isVisible,
            allowedContentTypes: services.fileImporter.allowedContentTypes,
            allowsMultipleSelection: services.fileImporter.multipleSelection,
            onCompletion: services.fileImporter.action
        )
    }
}
