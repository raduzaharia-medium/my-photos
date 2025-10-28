import SwiftUI

final class DeletePersonPresenter: ObservableObject {
    let confirmer: ConfirmationService

    init(confirmer: ConfirmationService) {
        self.confirmer = confirmer
    }

    @MainActor
    func show(_ person: Person) {
        withAnimation {
            confirmer.show(
                "Delete \(person.name)?",
                "Are you sure you want to delete this person?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        PersonIntents.delete(person)
                    }
                }
            )
        }

    }

    @MainActor
    func show(_ people: [Person]) {
        withAnimation {
            confirmer.show(
                "Delete \(people.count) Persons?",
                "Are you sure you want to delete these persons?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        PersonIntents.delete(people)
                    }
                }
            )
        }
    }
}
