import SwiftUI

@MainActor
final class NotificationService: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var message: String = ""
    @Published var style: ToastStyle = .success

    func show(_ message: String, _ style: ToastStyle) {
        withAnimation {
            self.message = message
            self.style = style
            self.isVisible = true
        }
    }
    func dismiss() {
        withAnimation {
            self.message = ""
            self.style = .success
            self.isVisible = false
        }
    }
}
