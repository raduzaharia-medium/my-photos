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
        
        return photosFromDates.intersection(photosFromTags).sorted {
            ($0.dateTaken ?? .distantPast) > ($1.dateTaken ?? .distantPast)
        }
    }

    func getPhotosBySelectedTags(_ filters: Set<SidebarItem>) -> Set<Photo> {
        var result = Set<Photo>()

        for tag in filters.selectedTags {
            result.formUnion(tag.photos)
        }

        return result
    }

    func getPhotosBySelectedDates(_ filters: Set<SidebarItem>) -> Set<Photo> {
        var result: Set<Photo> = []

        for year in filters.selectedYears {
            result = result.union(year.photos)
        }

        for month in filters.selectedMonths {
            result = result.union(month.photos)
        }

        for day in filters.selectedDays {
            result = result.union(day.photos)
        }

        return result
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
}
