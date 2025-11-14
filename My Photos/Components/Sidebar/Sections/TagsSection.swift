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
                    }.listRowSeparator(.hidden)

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
                }.listRowSeparator(.hidden)

            }
        }
    }
}

private struct TagRow: View {
    let tag: Tag

    var body: some View {
        SidebarRow(.tag(tag), isDraggable: true).tag(tag)
            .dropDestination(for: SidebarDropItem.self) { items, _ in
                var performedAny = false

                let photoIDs = items.photos.compactMap(\.id)
                let tags = items.tags
               
                if !photoIDs.isEmpty { PhotoIntents.requestChangeTag(tag: tag) }

                for incoming in tags {
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
