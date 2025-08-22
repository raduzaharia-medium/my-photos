import SwiftUI

enum ToastStyle {
    case success, error, info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.octagon.fill"
        case .info: return "info.circle.fill"
        }
    }
}

struct ToastBanner: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let message: String
    let style: ToastStyle

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: style.icon)
                .font(.title2)
                .symbolRenderingMode(.monochrome)
            Text(message)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .accessibilityLabel(message)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.separator.opacity(scheme == .dark ? 0.35 : 0.2))
        )
        .shadow(radius: 4)
        .transition(
            reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity)
        )
    }
}

private struct ToastModifier: ViewModifier {
    @State private var dismissTask: Task<Void, Never>?

    @Binding var isPresented: Bool
    let message: String
    let style: ToastStyle
    let duration: TimeInterval

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                if isPresented {
                    ToastBanner(message: message, style: style)
                        .padding(.top, 12)
                        .padding(.horizontal, 12)
                        .allowsHitTesting(true)
                        .onTapGesture {
                            withAnimation(.easeInOut) { isPresented = false }
                        }
                        // Schedule/cancel auto-dismiss safely
                        .task(id: isPresented) {
                            dismissTask?.cancel()
                            guard isPresented else { return }

                            #if canImport(UIKit)
                                UIAccessibility.post(
                                    notification: .announcement,
                                    argument: message
                                )
                                UINotificationFeedbackGenerator()
                                    .notificationOccurred(.success)
                            #endif

                            let task = Task { @MainActor in
                                try? await Task.sleep(
                                    nanoseconds: UInt64(
                                        duration * 1_000_000_000
                                    )
                                )
                                if !Task.isCancelled {
                                    withAnimation(.easeInOut) {
                                        isPresented = false
                                    }
                                }
                            }
                            dismissTask = task
                        }
                        .onDisappear { dismissTask?.cancel() }
                }
            }
    }
}

extension View {
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        style: ToastStyle = .success,
        duration: TimeInterval = 2
    ) -> some View {
        self.modifier(
            ToastModifier(
                isPresented: isPresented,
                message: message,
                style: style,
                duration: duration
            )
        )
    }
}
