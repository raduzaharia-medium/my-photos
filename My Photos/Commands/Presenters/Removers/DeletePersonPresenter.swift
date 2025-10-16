import SwiftUI

final class DeletePersonPresenter: ObservableObject {
    let alerter: AlertService

    init(alerter: AlertService) {
        self.alerter = alerter
    }

    @MainActor
    func show(_ person: Person) {
        withAnimation {
            alerter.show(
                "Delete \(person.name)?",
                "Are you sure you want to delete this person?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        PersonIntents.delete(person)
                        AppIntents.resetPhotoFilter()
                    }
                }
            )
        }

    }

    @MainActor
    func show(_ people: [Person]) {
        withAnimation {
            alerter.show(
                "Delete \(people.count) Persons?",
                "Are you sure you want to delete these persons?",
                actionLabel: "Delete",
                onAction: {
                    withAnimation {
                        PersonIntents.delete(people)
                        AppIntents.resetPhotoFilter()
                    }
                }
            )
        }
    }
}
