import SwiftUI

extension Notification.Name {
    static let requestCreatePerson = Notification.Name("requestCreatePerson")
    static let requestEditPerson = Notification.Name("requestEditPerson")
    static let requestDeletePerson = Notification.Name("requestDeletePerson")
    static let requestDeletePeople = Notification.Name("requestDeletePeople")

    static let createPerson = Notification.Name("createPerson")
    static let editPerson = Notification.Name("editPerson")
    static let deletePerson = Notification.Name("deletePerson")
    static let deletePeople = Notification.Name("deletePeople")
}

enum PersonIntents {
    static func requestCreate() {
        NotificationCenter.default.post(name: .requestCreatePerson, object: nil)
    }
    static func requestEdit(_ person: Person) {
        NotificationCenter.default.post(name: .requestEditPerson, object: person)
    }
    static func requestDelete(_ person: Person) {
        NotificationCenter.default.post(name: .requestDeletePerson, object: person)
    }
    static func requestDelete(_ people: [Person]) {
        NotificationCenter.default.post(
            name: .requestDeletePeople,
            object: people
        )
    }

    static func create(name: String) {
        NotificationCenter.default.post(name: .createPerson, object: name)
    }
    static func edit(_ person: Person, name: String) {
        NotificationCenter.default.post(
            name: .editPerson,
            object: person,
            userInfo: ["name": name]
        )
    }
    static func delete(_ person: Person) {
        NotificationCenter.default.post(name: .deletePerson, object: person)
    }
    static func delete(_ people: [Person]) {
        NotificationCenter.default.post(name: .deletePeople, object: people)
    }
}
