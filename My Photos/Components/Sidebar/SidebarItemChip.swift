import SwiftUI

struct SidebarItemChip: View {
    let item: SidebarItem
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Label {
                Text(item.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
            } icon: {
                Image(systemName: item.icon)
                    .symbolRenderingMode(.hierarchical)
            }

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule().stroke(.quaternary, lineWidth: 1)
        )
        .layoutPriority(1)
    }
}
