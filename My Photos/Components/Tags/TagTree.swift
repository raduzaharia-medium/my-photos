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
            .contentShape(Rectangle())
            .dropDestination(for: SidebarDropItem.self, isEnabled: true) { items, session in
                if let tagItem = items.compactMap({ item -> TagDragItem? in
                    if case .tag(let t) = item { return t }
                    return nil
                }).first {
                    if let dragged = state.getTag(tagItem.id) {
                        AppIntents.editTag(
                            dragged,
                            name: dragged.name,
                            kind: tag.kind,
                            parent: tag
                        )
                        AppIntents.loadTags()
                    }
                }

                if let photoItem = items.compactMap({ item -> PhotoDragItem? in
                    if case .photo(let p) = item { return p }
                    return nil
                }).first {
                    if let dragged = state.getPhoto(photoItem.id) {
                        // TODO: Implement your tagging flow here
                        // e.g., AppIntents.tagPhotos([dragged], with: tag)
                        print("Dropped photo: \(dragged) onto tag: \(tag.name)")
                    }
                }
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
