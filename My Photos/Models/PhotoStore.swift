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
}
