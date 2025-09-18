import SwiftUI

@MainActor
final class AlertService: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var actionLabel: String = ""
    @Published var cancelLabel: String = ""

    private var actionHandler: (() -> Void)?
    private var cancelHandler: (() -> Void)?

    func show(
        _ title: String,
        _ message: String,
        actionLabel: String = "",
        cancelLabel: String = "",
        onAction: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        withAnimation {
            self.isVisible = true

            self.title = title
            self.message = message
            self.actionLabel = actionLabel
            self.cancelLabel = cancelLabel

            self.actionHandler = onAction
            self.cancelHandler = onCancel
        }
    }
    func show(
        _ title: String,
        _ message: String,
        actionLabel: String = "",
        cancelLabel: String = "",
        onAction: (() -> Void)? = nil,
    ) {
        show(
            title,
            message,
            actionLabel: actionLabel,
            cancelLabel: cancelLabel,
            onAction: onAction,
            onCancel: nil
        )
    }
    func show(
        _ title: String,
        _ message: String,
        actionLabel: String = "",
        onAction: (() -> Void)? = nil,
    ) {
        show(
            title,
            message,
            actionLabel: actionLabel,
            cancelLabel: "Cancel",
            onAction: onAction
        )
    }

    func dismiss() {
        withAnimation {
            self.title = ""
            self.message = ""
            self.actionLabel = ""
            self.cancelLabel = ""
            self.actionHandler = nil
            self.cancelHandler = nil
            self.isVisible = false
        }
    }

    func action() {
        actionHandler?()
        dismiss()
    }

    func cancel() {
        cancelHandler?()
        dismiss()
    }
}
