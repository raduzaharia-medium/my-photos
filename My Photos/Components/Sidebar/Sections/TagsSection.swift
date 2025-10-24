import SwiftData
import SwiftUI

struct TagsSection: View {
    @Query(filter: #Predicate<Tag> { $0.parent == nil }, sort: \Tag.key) private
        var tags: [Tag]

    var body: some View {
        Section("Tags") {
            ForEach(tags) { tag in
                if tag.children.isEmpty {
                    TagRow(tag: tag)
                } else {
                    DisclosureGroup {
                        TagSectionChildren(parent: tag)
                    } label: {
                        TagRow(tag: tag)
                    }
                }
            }
        }
    }
}

private struct TagSectionChildren: View {
    @Query private var tags: [Tag]
    let parent: Tag

    init(parent: Tag) {
        self.parent = parent
        self._tags = Query(parentKey: parent.key)
    }

    var body: some View {
        ForEach(tags) { tag in
            if tag.children.isEmpty {
                TagRow(tag: tag)
            } else {
                DisclosureGroup {
                    TagSectionChildren(parent: tag)
                } label: {
                    TagRow(tag: tag)
                }
            }
        }
    }
}

private struct TagRow: View {
    let tag: Tag

    var body: some View {
        HStack(spacing: 8) {
            // Drag handle only for tags
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
                .draggable(TagDragItem(tag.id))

            // The rest of the row remains interactive for taps/selection, not drag
            SidebarRow(.tag(tag))
                .tag(tag)
        }
        // Keep drop destination on the whole row so dropping onto the row works
        .dropDestination(for: TagDragItem.self) { items, _ in
            var performedAny = false

            for incoming in items {
                var current: Tag? = tag
                while let node = current {
                    if node.id == incoming.id { return false }
                    current = node.parent
                }

                TagIntents.edit(incoming.id, parent: tag)
                performedAny = true
            }

            return performedAny
        }
    }
}

extension Query where Element == Tag, Result == [Tag] {
    fileprivate init(parentKey: String) {
        let filter = #Predicate<Tag> { $0.parent?.key == parentKey }
        let sort = [SortDescriptor(\Tag.key)]

        self.init(filter: filter, sort: sort)
    }
}
