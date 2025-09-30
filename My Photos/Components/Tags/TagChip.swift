import SwiftUI

struct TagChip: View {
    let tag: Tag
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Label(tag.name, systemImage: tag.kind.icon)
                .labelStyle(.titleAndIcon)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule().stroke(.quaternary, lineWidth: 1)
        )
    }
}
