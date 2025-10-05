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
            .dropDestination(for: SidebarDropItem.self, isEnabled: true) {
                items,
                _ in
                if !items.tags.isEmpty { handleTagDrop(items.tags) }
                if !items.photos.isEmpty { handlePhotoDrop(items.photos) }
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

    private func handleTagDrop(_ tagItems: [TagDragItem]) {
        var didChange = false
        for tagItem in tagItems {
            if let dragged = state.getTag(tagItem.id) {
                AppIntents.editTag(
                    dragged,
                    name: dragged.name,
                    kind: tag.kind,
                    parent: tag
                )
                didChange = true
            }
        }
        if didChange {
            AppIntents.loadTags()
        }
    }

    private func handlePhotoDrop(_ photoItems: [PhotoDragItem]) {
        for photoItem in photoItems {
            if let dragged = state.getPhoto(photoItem.id) {
                AppIntents.tagSelectedPhotos([tag])
                AppIntents.toggleSelectionMode()
            }
        }
    }
}
