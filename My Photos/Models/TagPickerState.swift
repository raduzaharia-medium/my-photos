import Observation

@MainActor
@Observable
final class TagPickerState {
    var searchText: [TagKind: String] = [:]
    var tags: [TagKind: Set<Tag>] = [:]
    var selectedIndex: [TagKind: Int?] = [:]

    var allTags: [Tag] { tags.flatMap(\.value) }

    func addTag(_ tag: Tag) {
        if tags[tag.kind] == nil { tags[tag.kind] = [] }
        tags[tag.kind]?.insert(tag)

        searchText[tag.kind] = ""
        selectedIndex[tag.kind] = nil
    }

    func removeTag(_ tag: Tag) {
        tags[tag.kind]?.remove(tag)
    }

    func selectNext(_ kind: TagKind, _ count: Int) {
        guard count > 0 else { return }

        let current = selectedIndex[kind]

        if current == nil {
            selectedIndex[kind] = 0
        } else {
            selectedIndex[kind] = min(current!! + 1, count - 1)
        }
    }

    func selectPrevious(_ kind: TagKind, _ count: Int) {
        guard count > 0 else { return }
        guard let current = selectedIndex[kind] else { return }
        guard let current else { return }

        selectedIndex[kind] = max(current - 1, 0)
    }

    func addSelection(_ kind: TagKind, _ suggestions: [Tag]) {
        guard let index = selectedIndex[kind] else { return }
        guard let index else { return }

        addTag(suggestions[index])
    }
}
