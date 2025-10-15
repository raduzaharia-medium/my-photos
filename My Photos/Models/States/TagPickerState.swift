import Observation

@MainActor
@Observable
final class TagPickerState {
    var tags: Set<Tag> = []
    var selectedIndex: Int?
    var suggestions: [Tag] = []

    func addTag(_ tag: Tag) {
        tags.insert(tag)
        selectedIndex = nil
    }

    func removeTag(_ tag: Tag) {
        tags.remove(tag)
    }

    func selectNext() {
        let count = suggestions.count
        let current = selectedIndex

        if current == nil {
            selectedIndex = 0
        } else {
            selectedIndex = min(current! + 1, count - 1)
        }
    }

    func selectPrevious() {
        guard let current = selectedIndex else { return }
        selectedIndex = max(current - 1, 0)
    }

    func addSelection() {
        guard let index = selectedIndex else { return }
        addTag(suggestions[index])
    }
}
