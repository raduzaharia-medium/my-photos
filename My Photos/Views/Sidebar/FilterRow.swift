import SwiftUI

struct FilterRow: View {
    let filter: Filter

    init(_ filter: Filter) {
        self.filter = filter
    }

    var body: some View {
        HStack {
            Label(filter.name, systemImage: filter.icon)
            Spacer(minLength: 8)
        }
        .contentShape(Rectangle())
        .tag(SidebarItem.filter(filter))
    }
}
