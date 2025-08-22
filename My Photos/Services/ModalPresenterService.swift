import SwiftUI

@MainActor
protocol ModalPresenter: AnyObject {
    func show<Content: View>(
        onDismiss: (() -> Void)?,
        @ViewBuilder _ content: @escaping () -> Content
    )
    func dismiss()
}

@MainActor
final class ModalPresenterService: ObservableObject, ModalPresenter {
    struct Item: Identifiable {
        let id = UUID()
        let content: AnyView
        let onDismiss: (() -> Void)?
    }

    @Published var item: Item?

    func show<Content: View>(
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        withAnimation {
            item = Item(content: AnyView(content()), onDismiss: onDismiss)
        }
    }

    func dismiss() {
        let onDismiss = item?.onDismiss
        withAnimation { item = nil }
        onDismiss?()
    }
}
