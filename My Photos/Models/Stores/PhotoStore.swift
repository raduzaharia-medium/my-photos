import SwiftData
import SwiftUI

@ModelActor
actor PhotoStore {
    func get(by fullPath: String) throws -> Photo? {
        let descriptor = FetchDescriptor<Photo>(
            predicate: #Predicate { $0.fullPath == fullPath }
        )

        return (try? modelContext.fetch(descriptor))?.first
    }

    func exists(_ fullPath: String) async throws -> Bool {
        let existing = try? get(by: fullPath)
        return existing != nil
    }
    func lastModifiedDate(_ fullPath: String) async throws -> Date? {
        let existing = try? get(by: fullPath)
        return existing?.lastModifiedDate ?? nil
    }

    func insert(_ photo: Photo) throws {
        modelContext.insert(photo)
        try modelContext.save()
    }
    func insert(_ photos: [Photo]) throws {
        for photo in photos {
            modelContext.insert(photo)
        }

        try modelContext.save()
    }

    func `import`(_ parsed: ParsedPhoto) async throws {
        let modified = try? await lastModifiedDate(parsed.fullPath)
        let notChanged = modified == parsed.lastModifiedDate
        guard modified == nil || notChanged == false else { return }

        let snapshot = try ensure(parsed)
        try? await insert(snapshot)
    }

    func tagPhotos(_ photos: [Photo], _ tags: [SidebarItem]) throws {
        for photo in photos {
            for tag in tags {
                if !photo.tags.contains(where: { $0.id == tag.id }) {
                    if case .album(let album) = tag { photo.addAlbum(album) }
                    if case .person(let person) = tag {
                        photo.addPerson(person)
                    }
                    if case .event(let event) = tag { photo.addEvent(event) }
                    if case .tag(let tag) = tag { photo.addTag(tag) }
                }
            }
        }

        try modelContext.save()
    }
}
