import SwiftData
import SwiftUI

// TODO: Split in TagCommands and LibraryCommands
struct LibraryCommands: Commands {
    @ObservedObject var modalPresenter: ModalPresenterService
    @ObservedObject var alerter: AlertService
    @ObservedObject var fileImporter: FileImportService
    @ObservedObject var notifier: NotificationService
    @ObservedObject var tagSelectionModel: TagSelectionModel

    var tagActions: TagActions

    init(
        tagActions: TagActions,
        modalPresenter: ModalPresenterService,
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

        self.tagActions = tagActions
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
                    tagActions: tagActions
                )
            }
            .keyboardShortcut("T", modifiers: [.command, .shift])

            Button("Edit Tag…") {
                guard let tag = tagSelectionModel.singleTag else { return }

                presentTagEditor(
                    tag,
                    modalPresenter: modalPresenter,
                    notifier: notifier,
                    tagActions: tagActions
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
                    tagActions: tagActions,
                    tagSelectionModel: tagSelectionModel
                )
            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
            .disabled(tagSelectionModel.singleTag == nil)
        }
    }
}
