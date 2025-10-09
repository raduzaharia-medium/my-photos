import SwiftUI

final class TagInputState: ObservableObject {
    @Published var searchText: String = ""
    @Published var selected: [Tag] = []
    @Published var highlightedIndex: Int? = nil

    let kind: TagKind

    init(_ kind: TagKind) {
        self.kind = kind
    }

    func addTag(_ tag: Tag) {
        if !selected.contains(where: { $0.id == tag.id }) {
            selected.append(tag)
        }

        searchText = ""
        highlightedIndex = nil
    }

    func removeTag(tag: Tag) {
        selected.removeAll { $0.id == tag.id }
    }

    @MainActor
    func submitFromKeyboard(suggestions: [Tag]) {
        if let index = highlightedIndex, suggestions.indices.contains(index) {
            addTag(suggestions[index])
        }
    }

    @MainActor
    func highlightNext(count: Int) {
        guard count > 0 else { return }
        let current = highlightedIndex ?? 0

        highlightedIndex = min(current + 1, count - 1)
    }

    @MainActor
    func highlightPrevious(count: Int) {
        guard count > 0 else { return }
        let current = highlightedIndex ?? 0

        highlightedIndex = max(current - 1, 0)
    }
}

@MainActor
final class PickTagPresenter: ObservableObject {
    private let people: TagInputState
    private let places: TagInputState
    private let events: TagInputState

    let modalPresenter: ModalService
    
    init(modalPresenter: ModalService) {
        self.modalPresenter = modalPresenter

        self.people = TagInputState(.person)
        self.places = TagInputState(.place)
        self.events = TagInputState(.event)
    }

    @MainActor
    func show() {
        withAnimation {
            modalPresenter.show(onDismiss: {}) {
                TagPickerSheet(
                    people: self.people,
                    places: self.places,
                    events: self.events,
                    onSave: { tags in
                        AppIntents.tagSelectedPhotos(tags)
                        AppIntents.toggleSelectionMode()

                        self.modalPresenter.dismiss()
                    },
                    onCancel: { self.modalPresenter.dismiss() }
                )
            }
        }
    }
}
