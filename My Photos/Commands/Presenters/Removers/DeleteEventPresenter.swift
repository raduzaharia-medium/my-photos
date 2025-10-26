import SwiftUI

final class DeleteEventPresenter: ObservableObject {
    let confirmer: ConfirmationService

    init(confirmer: ConfirmationService) {
        self.confirmer = confirmer
    }

    @MainActor
    func show(_ event: Event) {
        withAnimation {
            confirmer.show(
                "Delete \(event.name)?",
                "Are you sure you want to delete this event?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        EventIntents.delete(event)
                    }
                }
            )
        }

    }

    @MainActor
    func show(_ events: [Event]) {
        withAnimation {
            confirmer.show(
                "Delete \(events.count) Events?",
                "Are you sure you want to delete these events?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        EventIntents.delete(events)
                    }
                }
            )
        }
    }
}
