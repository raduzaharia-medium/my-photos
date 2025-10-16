import SwiftData
import SwiftUI

struct TagsSection: View {
    @Query(filter: #Predicate<Tag> { $0.parent == nil }, sort: \Tag.key) private var tags: [Tag]

    var body: some View {
        Section("Tags") {
            ForEach(tags) { tag in
                if tag.children.isEmpty {
                    SidebarRow(.tag(tag)).tag(tag)
                } else {
                    DisclosureGroup {
                        TagSectionChildren(parent: tag)
                    } label: {
                        SidebarRow(.tag(tag)).tag(tag)
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
                SidebarRow(.tag(tag)).tag(tag)
            } else {
                DisclosureGroup {
                    TagSectionChildren(parent: tag)
                } label: {
                    SidebarRow(.tag(tag)).tag(tag)
                }
            }
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
