import SwiftUI

extension View {
    func presentTagRemover(_ tag: Tag, alerter: AlertService, notifier: NotificationService, tagStore: TagStore, tagSelectionModel: TagSelectionModel) {
        My_Photos.presentTagRemover(tag, alerter: alerter, notifier: notifier, tagStore: tagStore, tagSelectionModel: tagSelectionModel)
    }
    
    func presentTagsRemover(_ tags: [Tag], alerter: AlertService, notifier: NotificationService, tagStore: TagStore, tagSelectionModel: TagSelectionModel) {
        My_Photos.presentTagsRemover(tags, alerter: alerter, notifier: notifier, tagStore: tagStore, tagSelectionModel: tagSelectionModel)
    }
}

@MainActor
func presentTagRemover(_ tag: Tag, alerter: AlertService, notifier: NotificationService, tagStore: TagStore, tagSelectionModel: TagSelectionModel) {
    withAnimation {
        alerter.show(
            "Delete \(tag.name)?",
            "Are you sure you want to delete this tag?",
            actionLabel: "Delete",
            onAction: {
                withAnimation {
                    do {
                        try tagStore.delete(tag.id)
                        
                        tagSelectionModel.selection.removeAll()
                        notifier.show("Tag deleted", .success)
                    }
                    catch {
                        notifier.show("Could not delete tag", .error)
                    }
                }
            }
        )
    }
}

@MainActor
func presentTagsRemover(_ tags: [Tag], alerter: AlertService, notifier: NotificationService, tagStore: TagStore, tagSelectionModel: TagSelectionModel) {
    withAnimation {
        alerter.show(
            "Delete \(tags.count) Tags?",
            "Are you sure you want to delete these tags?",
            actionLabel: "Delete",
            onAction: {
                withAnimation {
                    do {
                        try tagStore.delete(tags.map(\.id))
                        
                        tagSelectionModel.selection.removeAll()
                        notifier.show("Tags deleted", .success)
                    }
                    catch {
                        notifier.show("Could not delete tags", .error)
                    }
                }
            }
        )
    }
}
