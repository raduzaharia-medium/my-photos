import SwiftData
import SwiftUI

final class PersonStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func create(name: String) throws -> Person {
        let person = Person(name)

        context.insert(person)
        try context.save()

        return person
    }

    @discardableResult
    func update(_ person: Person, name: String) throws -> Person {
        guard let person = context.model(for: person.id) as? Person else {
            throw StoreError.notFound
        }

        person.name = name
        try context.save()

        return person
    }

    func delete(_ person: Person) throws {
        guard let person = context.model(for: person.id) as? Person else {
            throw StoreError.notFound
        }

        context.delete(person)
        try context.save()
    }

    func delete(_ people: [Person]) throws {
        guard !people.isEmpty else { return }

        for person in people {
            guard let person = context.model(for: person.id) as? Person else {
                throw StoreError.notFound
            }

            context.delete(person)
        }

        try context.save()
    }
}
