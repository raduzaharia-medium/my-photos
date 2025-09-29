import SwiftUI
import UniformTypeIdentifiers

struct TagTree: View {
    let tag: Tag
    let kind: TagKind

    @Environment(PresentationState.self) private var presentationState

    @ViewBuilder
    private var row: some View {
        SidebarRow(.tag(tag))
            .draggable(TagDragItem(name: tag.name, kind: tag.kind))
            .dropDestination(for: TagDragItem.self) { items, location in
                guard let incoming = items.first else { return false }
                guard
                    let dragged = presentationState.tags.first(where: {
                        $0.name == incoming.name && $0.kind == incoming.kind
                    })
                else { return false }
                guard dragged.persistentModelID != tag.persistentModelID else {
                    return false
                }

                var current: Tag? = tag.parent
                while let c = current {
                    if c.persistentModelID == dragged.persistentModelID {
                        return false
                    }

                    current = c.parent
                }

                AppIntents.editTag(
                    dragged,
                    name: dragged.name,
                    kind: currentTag.kind,
                    parent: currentTag
                )
                AppIntents.loadTags()

                return true
            } isTargeted: { _ in
            }
    }

    private var children: [Tag] {
        presentationState.tags
            .filter {
                $0.kind == kind && $0.parent?.persistentModelID == tag.persistentModelID
            }
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
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
