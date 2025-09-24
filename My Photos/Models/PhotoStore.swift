import SwiftData
import SwiftUI

final class PhotoStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
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
        let selectedTags = filters.selectedTags
        let selectedTagNames = selectedTags.map(\.name)
        var descriptor = FetchDescriptor<Photo>(
            sortBy: [SortDescriptor(\Photo.dateTaken, order: .reverse)]
        )

        if !selectedTags.isEmpty {
            descriptor.predicate = #Predicate<Photo> { photo in
                photo.tags.contains { tag in
                    selectedTagNames.contains(tag.name)
                }
            }
        }

        return (try? context.fetch(descriptor)) ?? []
    }
    
    func tagPhotos(_ photos: Set<Photo>, _ tag: Tag) throws {
        for photo in photos {
            photo.tags.append(tag)
        }
        
        try context.save()
    }
}
