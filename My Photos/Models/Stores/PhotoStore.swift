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

    private func photosForCountry(key: String) -> Set<Photo> {
        let descriptor = FetchDescriptor<PlaceCountry>(
            predicate: #Predicate { $0.key == key }
        )
        if let model = try? modelContext.fetch(descriptor).first {
            return Set(model.photos)
        }
        return []
    }

    private func photosForLocality(key: String) -> Set<Photo> {
        let descriptor = FetchDescriptor<PlaceLocality>(
            predicate: #Predicate { $0.key == key }
        )
        if let model = try? modelContext.fetch(descriptor).first {
            return Set(model.photos)
        }
        return []
    }
}
