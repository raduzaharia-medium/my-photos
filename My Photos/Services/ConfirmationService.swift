import SwiftUI

@MainActor
final class ConfirmationService: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var actionLabel: String = ""

    private var actionHandler: (() -> Void)?

    func show(
        _ title: String,
        _ message: String,
        actionLabel: String = "",
        onAction: (() -> Void)? = nil,
    ) {
        withAnimation {
            self.isVisible = true

            self.title = title
            self.message = message
            self.actionLabel = actionLabel

            self.actionHandler = onAction
        }
    }

    func action() {
        actionHandler?()
    }
}
