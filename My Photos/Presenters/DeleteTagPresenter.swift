import SwiftUI

class DeleteTagPresenter: ObservableObject {
    let alerter: AlertService
    let notifier: NotificationService
    let tagStore: TagStore

    init(
        alerter: AlertService,
        notifier: NotificationService,
        tagStore: TagStore,
    ) {
        self.alerter = alerter
        self.notifier = notifier
        self.tagStore = tagStore
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

                            AppIntents.resetTagSelection()
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

                            NotificationCenter.default.post(name: .resetTagSelection, object: nil)
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
