import Observation

@MainActor
@Observable
final class TagPickerState {
    var tags: [TagKind: Set<Tag>] = [:]
    var selectedIndex: [TagKind: Int?] = [:]
    var suggestions: [TagKind: [Tag]] = [:]

    var allTags: [Tag] { tags.flatMap(\.value) }

    func addTag(_ tag: Tag) {
        if tags[tag.kind] == nil { tags[tag.kind] = [] }
        tags[tag.kind]?.insert(tag)

        selectedIndex[tag.kind] = nil
    }

    func removeTag(_ tag: Tag) {
        tags[tag.kind]?.remove(tag)
    }

    func selectNext(_ kind: TagKind) {
        guard let count = suggestions[kind]?.count else { return }

        let current = selectedIndex[kind]

        if current == nil {
            selectedIndex[kind] = 0
        } else {
            selectedIndex[kind] = min(current!! + 1, count - 1)
        }
    }

    func selectPrevious(_ kind: TagKind) {
        guard let current = selectedIndex[kind] else { return }
        guard let current else { return }

        selectedIndex[kind] = max(current - 1, 0)
    }

    func addSelection(_ kind: TagKind) {
        guard let index = selectedIndex[kind] else { return }
        guard let index else { return }
        guard let suggestions = suggestions[kind] else { return }

        addTag(suggestions[index])
    }
}
