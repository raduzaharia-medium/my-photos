import SwiftUI

struct CountBadge: View {
    let count: Int

    var body: some View {
        let text = count > 99 ? "99+" : String(count)
        let size: CGFloat = count < 10 ? 22 : (count < 100 ? 26 : 30)

        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(.red)
            )
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.9), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
            .padding(4)
            .accessibilityLabel("\(count) items")
    }
}
