import SwiftData
import SwiftUI

@MainActor
final class TagActions: ObservableObject {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func create(name: String, kind: TagKind) {
        let tag = Tag(name: name, kind: kind)
        
        context.insert(tag)
        try? context.save()
    }
    
    func update(_ id: PersistentIdentifier, name: String, kind: TagKind) {
        if let tag = context.model(for: id) as? Tag {
            tag.name = name
            tag.kind = kind
            
            try? context.save()
        }
    }
    
    func upsert(_ id: PersistentIdentifier?, name: String, kind: TagKind) {
        if let id {
            update(id, name: name, kind: kind)
        } else {
            create(name: name, kind: kind)
        }
    }
    
    func delete(_ id: PersistentIdentifier) {
        if let tag = context.model(for: id) as? Tag {
            context.delete(tag)
            try? context.save()
        }
    }
    
    func delete(_ ids: [PersistentIdentifier]) {
        guard !ids.isEmpty else { return }
        
        for id in ids {
            if let tag = context.model(for: id) as? Tag {
                context.delete(tag)
            }
        }
        
        try? context.save()
    }
    
    
}
