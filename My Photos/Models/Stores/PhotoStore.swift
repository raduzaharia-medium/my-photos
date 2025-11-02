import SwiftData
import SwiftUI

final class PhotoStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
    
    func get(by fullPath: String) throws -> Photo? {
        let descriptor = FetchDescriptor<Photo>(
            predicate: #Predicate { $0.fullPath == fullPath }
        )

        return (try? context.fetch(descriptor))?.first
    }

    func insert(_ photo: Photo) throws {
        context.insert(photo)
        try context.save()
    }
    func insert(_ photos: [Photo]) throws {
        for photo in photos {
            context.insert(photo)
        }

        try context.save()
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

        try context.save()
    }

    private func photosForCountry(key: String) -> Set<Photo> {
        let descriptor = FetchDescriptor<PlaceCountry>(
            predicate: #Predicate { $0.key == key }
        )
        if let model = try? context.fetch(descriptor).first {
            return Set(model.photos)
        }
        return []
    }

    private func photosForLocality(key: String) -> Set<Photo> {
        let descriptor = FetchDescriptor<PlaceLocality>(
            predicate: #Predicate { $0.key == key }
        )
        if let model = try? context.fetch(descriptor).first {
            return Set(model.photos)
        }
        return []
    }
}
