import SwiftData
import SwiftUI

final class PhotoStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
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

    func tagPhotos(_ photos: Set<Photo>, _ tags: [Tag]) throws {
        for photo in photos {
            for tag in tags {
                if !photo.tags.contains(where: { $0.id == tag.id }) {
                    photo.tags.append(tag)
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
