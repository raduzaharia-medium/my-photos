import SwiftData
import SwiftUI

enum TagActionError: Error {
    case tagNotFound
    case saveFailed(underlying: Error)
}

@MainActor
final class TagActions: ObservableObject {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func create(name: String, kind: TagKind) throws {
        let tag = Tag(name: name, kind: kind)

        context.insert(tag)
        try context.save()
    }

    func update(_ id: PersistentIdentifier, name: String, kind: TagKind) throws
    {
        guard let tag = context.model(for: id) as? Tag else {
            throw TagActionError.tagNotFound
        }

        tag.name = name
        tag.kind = kind

        try context.save()
    }

    func upsert(_ id: PersistentIdentifier?, name: String, kind: TagKind) throws
    {
        if let id {
            try update(id, name: name, kind: kind)
        } else {
            try create(name: name, kind: kind)
        }
    }

    func delete(_ id: PersistentIdentifier) throws {
        guard let tag = context.model(for: id) as? Tag else {
            throw TagActionError.tagNotFound
        }

        context.delete(tag)
        try context.save()
    }

    func delete(_ ids: [PersistentIdentifier]) throws {
        guard !ids.isEmpty else { return }

        for id in ids {
            guard let tag = context.model(for: id) as? Tag else {
                throw TagActionError.tagNotFound
            }

            context.delete(tag)
        }

        try context.save()
    }
}
