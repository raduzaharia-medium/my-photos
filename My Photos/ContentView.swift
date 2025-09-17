import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
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
        .alert(
            services.alerter.title,
            isPresented: $services.alerter.isVisible
        ) {
            Button(services.alerter.actionLabel, role: .destructive) {
                services.alerter.action()
            }
            Button(services.alerter.cancelLabel, role: .cancel) {
                services.alerter.cancel()
            }
        } message: {
            Text(services.alerter.message)
        }
        .sheet(
            item: $services.modalPresenter.item,
            onDismiss: services.modalPresenter.item?.onDismiss
        ) { item in
            item.content
        }
        .fileImporter(
            isPresented: $services.fileImporter.isVisible,
            allowedContentTypes: services.fileImporter.allowedContentTypes,
            allowsMultipleSelection: services.fileImporter.multipleSelection,
            onCompletion: services.fileImporter.action
        )
    }
}
