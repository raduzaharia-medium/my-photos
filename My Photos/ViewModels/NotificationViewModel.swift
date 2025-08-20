import SwiftUI

@MainActor
protocol Notifier: AnyObject {
    func show(_ message: String)
    func dismiss()
}

@MainActor
final class NotificationViewModel: ObservableObject, Notifier {
    @Published var isVisible: Bool = false
    @Published var message: String = ""

    func show(_ message: String) {
        withAnimation {
            self.message = message
            self.isVisible = true
        }
    }
    func dismiss() {
        withAnimation {
            self.message = ""
            self.isVisible = false
        }
    }
}
