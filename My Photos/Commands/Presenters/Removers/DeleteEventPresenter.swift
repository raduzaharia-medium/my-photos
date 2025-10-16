import SwiftUI

final class DeleteEventPresenter: ObservableObject {
    let alerter: AlertService

    init(alerter: AlertService) {
        self.alerter = alerter
    }

    @MainActor
    func show(_ event: Event) {
        withAnimation {
            alerter.show(
                "Delete \(event.name)?",
                "Are you sure you want to delete this event?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        EventIntents.delete(event)
                        AppIntents.resetPhotoFilter()
                    }
                }
            )
        }

    }

    @MainActor
    func show(_ events: [Event]) {
        withAnimation {
            alerter.show(
                "Delete \(events.count) Events?",
                "Are you sure you want to delete these events?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        EventIntents.delete(events)
                        AppIntents.resetPhotoFilter()
                    }
                }
            )
        }
    }
}
