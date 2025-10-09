struct TagInputState {
    var searchText: String = ""
    var selected: [Tag] = []
    var highlightedIndex: Int? = nil
    let kind: TagKind

    init(_ kind: TagKind) {
        self.kind = kind
    }

    mutating func addTag(_ tag: Tag) {
        if !selected.contains(where: { $0.id == tag.id }) {
            selected.append(tag)
        }

        searchText = ""
        highlightedIndex = nil
    }

    mutating func removeTag(_ tag: Tag) {
        selected.removeAll { $0.id == tag.id }
    }

    mutating func submitFromKeyboard(_ suggestions: [Tag]) {
        if let index = highlightedIndex, suggestions.indices.contains(index) {
            addTag(suggestions[index])
        }
    }

    mutating func highlightNext(_ count: Int) {
        guard count > 0 else { return }
        let current = highlightedIndex ?? 0

        highlightedIndex = min(current + 1, count - 1)
    }

    mutating func highlightPrevious(_ count: Int) {
        guard count > 0 else { return }
        let current = highlightedIndex ?? 0

        highlightedIndex = max(current - 1, 0)
    }
}
