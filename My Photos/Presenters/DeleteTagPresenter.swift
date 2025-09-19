import SwiftUI

class DeleteTagPresenter: ObservableObject {
    let alerter: AlertService
    let notifier: NotificationService
    let tagStore: TagStore
    let tagSelectionModel: TagSelectionModel

    init(
        alerter: AlertService,
        notifier: NotificationService,
        tagStore: TagStore,
        tagSelectionModel: TagSelectionModel
    ) {
        self.alerter = alerter
        self.notifier = notifier
        self.tagStore = tagStore
        self.tagSelectionModel = tagSelectionModel
    }

    @MainActor
    func show(_ tag: Tag) {
        withAnimation {
            alerter.show(
                "Delete \(tag.name)?",
                "Are you sure you want to delete this tag?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        do {
                            try self.tagStore.delete(tag.id)

                            self.tagSelectionModel.selection.removeAll()
                            self.notifier.show("Tag deleted", .success)
                        } catch {
                            self.notifier.show("Could not delete tag", .error)
                        }
                    }
                }
            )
        }

    }

    @MainActor
    func show(_ tags: [Tag]) {
        withAnimation {
            alerter.show(
                "Delete \(tags.count) Tags?",
                "Are you sure you want to delete these tags?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        do {
                            try self.tagStore.delete(tags.map(\.id))

                            self.tagSelectionModel.selection.removeAll()
                            self.notifier.show("Tags deleted", .success)
                        } catch {
                            self.notifier.show("Could not delete tags", .error)
                        }
                    }
                }
            )
        }
    }
}
