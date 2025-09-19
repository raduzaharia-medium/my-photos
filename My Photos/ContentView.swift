import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var tagSelectionModel: TagSelectionModel

    @StateObject private var modalPresenter = ModalService()
    @StateObject private var alerter = AlertService()
    @StateObject private var fileImporter = FileImportService()
    @StateObject private var notifier = NotificationService()

    private var tagStore: TagStore { TagStore(context: context) }

    private var editTagPresenter: EditTagPresenter {
        EditTagPresenter(
            modalPresenter: modalPresenter,
            notifier: notifier,
            tagStore: tagStore
        )
    }

    private var importPhotosPresenter: ImportPhotosPresenter {
        ImportPhotosPresenter(
            fileImporter: fileImporter,
            notifier: notifier
        )
    }

    private var deleteTagPresenter: DeleteTagPresenter {
        DeleteTagPresenter(
            alerter: alerter,
            notifier: notifier,
            tagStore: tagStore,
            tagSelectionModel: tagSelectionModel
        )
    }

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
        .onReceive(
            NotificationCenter.default.publisher(for: .requestImportPhotos)
        ) { note in
            importPhotosPresenter.show()
        }
        .onReceive(NotificationCenter.default.publisher(for: .requestCreateTag))
        { note in
            editTagPresenter.show(nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: .requestEditTag)) {
            note in
            guard let tag = note.object as? Tag else { return }
            editTagPresenter.show(tag)
        }
        .onReceive(NotificationCenter.default.publisher(for: .requestDeleteTag))
        { note in
            guard let tag = note.object as? Tag else { return }
            deleteTagPresenter.show(tag)
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .requestDeleteTags)
        ) { note in
            guard let tags = note.object as? [Tag] else { return }
            deleteTagPresenter.show(tags)
        }
    }
}
