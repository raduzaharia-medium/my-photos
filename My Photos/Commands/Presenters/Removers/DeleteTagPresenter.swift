import SwiftUI

final class DeleteTagPresenter: ObservableObject {
    let confirmer: ConfirmationService

    init(confirmer: ConfirmationService) {
        self.confirmer = confirmer
    }

    @MainActor
    func show(_ tag: Tag) {
        withAnimation {
            confirmer.show(
                "Delete \(tag.name)?",
                "Are you sure you want to delete this tag?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        TagIntents.delete(tag)
                    }
                }
            )
        }

    }

    @MainActor
    func show(_ tags: [Tag]) {
        withAnimation {
            confirmer.show(
                "Delete \(tags.count) Tags?",
                "Are you sure you want to delete these tags?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        TagIntents.delete(tags)
                    }
                }
            )
        }
    }
}
