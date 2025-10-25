import SwiftUI

struct SidebarRow: View {
    @Environment(PresentationState.self) private var state

    let item: SidebarItem
    let isDraggable: Bool

    var isSelected: Bool { state.photoFilter.contains(item) }

    init(_ item: SidebarItem, isDraggable: Bool = false) {
        self.item = item
        self.isDraggable = isDraggable
    }

    var body: some View {
        HStack {
            Label(item.name, systemImage: item.icon)
            Spacer(minLength: 8)

            if isDraggable {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                    .draggable(TagDragItem(item.id))
            }

            Image(
                systemName: isSelected ? "checkmark.circle.fill" : "circle"
            )
            .tint(isSelected ? .accentColor : .secondary)
            .accessibilityLabel(isSelected ? "Selected" : "Not selected")
        }
        .contentShape(Rectangle().inset(by: -6))
        .tag(item)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.name)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .onTapGesture {
            withAnimation {
                if isSelected {
                    state.photoFilter.remove(item)
                } else {
                    state.photoFilter.insert(item)
                }
            }
        }.contextMenu { SidebarContextMenu(current: item) }
    }
}
