import SwiftUI
import SwiftData

// TODO: Split in TagCommands and LibraryCommands
struct LibraryCommands: Commands {
    @ObservedObject var tagActions: TagActions
    @ObservedObject var modalPresenter: ModalPresenterService
    @ObservedObject var alerter: AlertService
    @ObservedObject var tagViewModel: TagViewModel

    init(_ tagViewModel: TagViewModel, tagActions: TagActions, modalPresenter: ModalPresenterService, alerter: AlertService) {
        self._tagViewModel = ObservedObject(wrappedValue: tagViewModel)
        
        self._tagActions = ObservedObject(wrappedValue: tagActions)
        self._modalPresenter = ObservedObject(wrappedValue: modalPresenter)
        self._alerter = ObservedObject(wrappedValue: alerter)
    }

    var body: some Commands {
        CommandMenu("Library") {
            Button("Import Folder…") { tagViewModel.importFolder() }
                .keyboardShortcut("I", modifiers: [.command, .shift])

            Divider()

            Button("Create Tag…") {
                modalPresenter.show(onDismiss: {}) {
                    TagEditorSheet(
                        nil,
                        onSave: { original, name, kind in
                            withAnimation {
                                tagActions.upsert(original?.id, name: name, kind: kind)
                                modalPresenter.dismiss()
                            }
                        },
                        onCancel: { modalPresenter.dismiss() }
                    )
                }
            }
                .keyboardShortcut("T", modifiers: [.command, .shift])

            Button("Edit Tag…") {
                modalPresenter.show(onDismiss: {}) {
                    TagEditorSheet(
                        nil,
                        onSave: { original, name, kind in
                            withAnimation {
                                tagActions.upsert(original?.id, name: name, kind: kind)
                                modalPresenter.dismiss()
                            }
                        },
                        onCancel: { modalPresenter.dismiss() }
                    )
                }

            }
                .keyboardShortcut("E", modifiers: [.command, .shift])
                .disabled(tagViewModel.selectedTag == nil)

            Button("Delete Tag", role: .destructive) {
                let tag = Tag(name: "Aaa", kind: .album )
                
                alerter.show(
                    "Delete \(tag.name)?",
                    "Are you sure you want to delete this tag?",
                    actionLabel: "Delete",
                    onAction: {
                        tagActions.delete(tag.id)
                    }
                )

            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
            .disabled(tagViewModel.selectedTag == nil)
        }
    }
}
