import SwiftUI

final class DeleteFilterPresenter: ObservableObject {
    let confirmer: ConfirmationService

    init(confirmer: ConfirmationService) {
        self.confirmer = confirmer
    }

    @MainActor
    func show(_ filters: [SidebarItem]) {
        withAnimation {
            confirmer.show(
                "Delete \(filters.count) Items?",
                "Are you sure you want to delete these items?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        FilterIntents.delete(filters)
                    }
                }
            )
        }
    }
}
