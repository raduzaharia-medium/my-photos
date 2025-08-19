import SwiftUI

struct ToastBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
            Text(message)
                .font(.headline)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .shadow(radius: 4)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

extension View {
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        duration: TimeInterval = 2
    ) -> some View {
        ZStack(alignment: .top) {
            self
                .overlay(alignment: .top) {
                    if isPresented.wrappedValue {
                        ToastBanner(message: message)
                            .padding(.top, 12)
                            .zIndex(9999)
                            .allowsHitTesting(false)
                            .transition(
                                .move(edge: .top).combined(with: .opacity)
                            )
                            .onAppear {
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + duration
                                ) {
                                    withAnimation {
                                        isPresented.wrappedValue = false
                                    }
                                }
                            }
                    }
                }
                .animation(.easeInOut, value: isPresented.wrappedValue)
        }
    }
}
