import SwiftUI

struct FilterRow: View {
    let filter: Filter

    var body: some View {
        NavigationLink(value: SidebarItem.filter(filter)) {
            HStack {
                Label(filter.name, systemImage: filter.icon)
                Spacer(minLength: 8)
            }
            .contentShape(Rectangle())
        }
    }
}
