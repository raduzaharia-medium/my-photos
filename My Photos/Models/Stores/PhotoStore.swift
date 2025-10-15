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

    func getPhotos() -> [Photo] {
        let descriptor = FetchDescriptor<Photo>(
            sortBy: [
                SortDescriptor(\Photo.dateTaken, order: .reverse)
            ]
        )

        if let fetched = try? context.fetch(descriptor) { return fetched }
        return []
    }
    func getPhotos(_ filters: Set<SidebarItem>) -> [Photo] {
        let photosFromTags = getPhotosBySelectedTags(filters)
        let photosFromDates = getPhotosBySelectedDates(filters)
        let photosFromPlaces = getPhotosBySelectedPlaces(filters)

        return
            photosFromDates
            .intersection(photosFromTags)
            .intersection(photosFromPlaces)
            .sorted {
                ($0.dateTaken ?? .distantPast) > ($1.dateTaken ?? .distantPast)
            }
    }

    func getPhotosBySelectedTags(_ filters: Set<SidebarItem>) -> Set<Photo> {
        guard !filters.selectedTags.isEmpty else { return Set(getPhotos()) }

        let result = filters.selectedTags.reduce(into: Set<Photo>()) {
            partialResult,
            tag in
            partialResult.formUnion(tag.photos)
        }

        return result
    }

    func getPhotosBySelectedDates(_ filters: Set<SidebarItem>) -> Set<Photo> {
        guard !filters.selectedDates.isEmpty else { return Set(getPhotos()) }

        let result = filters.selectedDates.reduce(into: Set<Photo>()) {
            partialResult,
            dateTaken in
            switch dateTaken {
            case .year(let y):
                partialResult.formUnion(y.photos)
            case .month(let m):
                partialResult.formUnion(m.photos)
            case .day(let d):
                partialResult.formUnion(d.photos)
            }
        }

        return result
    }

    func getPhotosBySelectedPlaces(_ filters: Set<SidebarItem>) -> Set<Photo> {
        guard !filters.selectedPlaces.isEmpty else { return Set(getPhotos()) }

        return filters.selectedPlaces.reduce(into: Set<Photo>()) { partialResult, place in
            switch place {
            case .country(let c):
                if let model = c as? PlaceCountry {
                    partialResult.formUnion(model.photos)
                } else if let vm = c as? PlaceCountry {
                    partialResult.formUnion(photosForCountry(key: vm.key))
                } else {
                    if let key = (Mirror(reflecting: c).children.first { $0.label == "key" }?.value as? String) {
                        partialResult.formUnion(photosForCountry(key: key))
                    }
                }
            case .locality(let l):
                if let model = l as? PlaceLocality {
                    partialResult.formUnion(model.photos)
                } else if let vm = l as? PlaceLocality {
                    partialResult.formUnion(photosForLocality(key: vm.key))
                } else {
                    // Fallback: attempt by key via Mirror if available
                    if let key = (Mirror(reflecting: l).children.first { $0.label == "key" }?.value as? String) {
                        partialResult.formUnion(photosForLocality(key: key))
                    }
                }
            }
        }
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
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: #Predicate { $0.key == key })
        if let model = try? context.fetch(descriptor).first {
            return Set(model.photos)
        }
        return []
    }

    private func photosForLocality(key: String) -> Set<Photo> {
        let descriptor = FetchDescriptor<PlaceLocality>(predicate: #Predicate { $0.key == key })
        if let model = try? context.fetch(descriptor).first {
            return Set(model.photos)
        }
        return []
    }
}
