import SwiftUI
import UniformTypeIdentifiers

struct TagTree: View {
    let tag: Tag
    let kind: TagKind

    @Environment(PresentationState.self) private var state

    @ViewBuilder
    private var row: some View {
        SidebarRow(.tag(tag))
            .draggable(TagDragItem(tag.id))
            .dropDestination(for: TagDragItem.self) { items, location in
                for incoming in items {
                    let dragged = state.getTag(incoming.id)
                    guard let dragged else { return false }

                    AppIntents.editTag(
                        dragged,
                        name: dragged.name,
                        kind: tag.kind,
                        parent: tag
                    )
                }

                AppIntents.loadTags()
                return true
            } isTargeted: { _ in
            }
    }

    private var children: [Tag] {
        state.tags.filter { $0.kind == kind && $0.parent?.id == tag.id }
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name)
                    == .orderedAscending
            }
    }

    var body: some View {
        if children.isEmpty {
            row
        } else {
            DisclosureGroup(isExpanded: .constant(true)) {
                ForEach(children, id: \.persistentModelID) { child in
                    TagTree(tag: child, kind: kind)
                }
            } label: {
                row
            }
        }
    }
}
