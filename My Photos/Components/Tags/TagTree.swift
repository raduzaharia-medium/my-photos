import SwiftUI

struct TagTree: View {
    let tag: Tag
    let kind: TagKind

    private var children: [Tag] {
        tag.children
            .filter { $0.kind == kind }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        if children.isEmpty {
            SidebarRow(.tag(tag))
        } else {
            DisclosureGroup {
                ForEach(children, id: \.persistentModelID) { child in
                    TagTree(tag: child, kind: kind)
                }
            } label: {
                SidebarRow(.tag(tag))
            }
        }
    }
}
