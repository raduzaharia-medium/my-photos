import SwiftData
import SwiftUI

struct LibraryCommands: Commands {
    @ObservedObject var modalPresenter: ModalService
    @ObservedObject var alerter: AlertService
    @ObservedObject var fileImporter: FileImportService
    @ObservedObject var notifier: NotificationService
    @ObservedObject var tagSelectionModel: TagSelectionModel

    var tagStore: TagStore

    init(
        tagStore: TagStore,
        modalPresenter: ModalService,
        alerter: AlertService,
        fileImporter: FileImportService,
        notifier: NotificationService,
        tagSelectionModel: TagSelectionModel
    ) {
        self._modalPresenter = ObservedObject(wrappedValue: modalPresenter)
        self._alerter = ObservedObject(wrappedValue: alerter)
        self._fileImporter = ObservedObject(wrappedValue: fileImporter)
        self._notifier = ObservedObject(wrappedValue: notifier)
        self._tagSelectionModel = ObservedObject(
            wrappedValue: tagSelectionModel
        )

        self.tagStore = tagStore
    }

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") {
                presentImportPhotos(
                    fileImporter: fileImporter,
                    notifier: notifier
                )
            }
            .keyboardShortcut("I", modifiers: [.command, .shift])

            Divider()

            Button("Create Tag…") {
                presentTagEditor(
                    nil,
                    modalPresenter: modalPresenter,
                    notifier: notifier,
                    tagStore: tagStore
                )
            }
            .keyboardShortcut("T", modifiers: [.command, .shift])

            Button("Edit Tag…") {
                guard let tag = tagSelectionModel.singleTag else { return }

                presentTagEditor(
                    tag,
                    modalPresenter: modalPresenter,
                    notifier: notifier,
                    tagStore: tagStore
                )
            }
            .keyboardShortcut("E", modifiers: [.command, .shift])
            .disabled(tagSelectionModel.singleTag == nil)

            Button("Delete Tag", role: .destructive) {
                guard let tag = tagSelectionModel.singleTag else { return }

                presentTagRemover(
                    tag,
                    alerter: alerter,
                    notifier: notifier,
                    tagStore: tagStore,
                    tagSelectionModel: tagSelectionModel
                )
            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
            .disabled(tagSelectionModel.singleTag == nil)
        }
    }
}
