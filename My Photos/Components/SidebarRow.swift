import SwiftUI

struct SidebarRow: View {
    @Environment(PresentationState.self) private var state

    let item: SidebarItem

    init(_ item: SidebarItem) { self.item = item }

    var body: some View {
        HStack {
            Label(item.name, systemImage: item.icon)
            Spacer(minLength: 8)
        }
        .contentShape(Rectangle())
        .tag(item) 
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.name)
    }
}
