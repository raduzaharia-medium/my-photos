import SwiftUI

final class DeleteTagPresenter: ObservableObject {
    let alerter: AlertService

    init(alerter: AlertService) {
        self.alerter = alerter
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
                        TagIntents.delete(tag)
                        AppIntents.resetPhotoFilter()
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
                        TagIntents.delete(tags)
                        AppIntents.resetPhotoFilter()
                    }
                }
            )
        }
    }
}
