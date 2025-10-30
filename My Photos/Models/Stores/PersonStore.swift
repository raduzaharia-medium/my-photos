import SwiftData
import SwiftUI

final class PersonStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
    
    func get(_ name: String) -> Person? {
        let key = "\(name)"
        let descriptor = FetchDescriptor<Person>(
            predicate: #Predicate { $0.key == key }
        )

        return (try? context.fetch(descriptor))?.first
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
    
    func ensure(_ name: String?) throws -> Person? {
        guard let name else { return nil }
        let ensured = try findOrCreate(name)

        return ensured
    }

    func ensure(_ names: [String]) -> [Person] {
        var result: [Person] = []

        for name in names {
            if let ensured = try? ensure(name) {
                result.append(ensured)
            }
        }

        return result
    }

    private func findOrCreate(_ name: String) throws -> Person {
        if let existing = get(name) { return existing }
        let newNode = Person(name)

        context.insert(newNode)
        try context.save()
        return newNode
    }
}
