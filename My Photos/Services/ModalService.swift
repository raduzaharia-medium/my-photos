import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let content: AnyView
    let onDismiss: (() -> Void)?
}

@MainActor
final class ModalService: ObservableObject {
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

