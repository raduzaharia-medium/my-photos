import SwiftUI

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
