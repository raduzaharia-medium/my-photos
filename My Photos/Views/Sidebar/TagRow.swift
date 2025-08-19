import SwiftUI

struct TagRow: View {
    let tag: Tag

    init(
        _ tag: Tag,
    ) {
        self.tag = tag
    }

    var body: some View {
        HStack {
            Label(tag.name, systemImage: tag.kind.icon)
            Spacer(minLength: 8)
        }
        .contentShape(Rectangle())
        .tag(SidebarItem.tag(tag))
    }
}
