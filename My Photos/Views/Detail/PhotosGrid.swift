import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    let tag: Tag?

    private var photos: [Photo] {
        if let tag {
            return tag.photos.sorted { $0.dateTaken > $1.dateTaken }
        } else {
            return allPhotos
        }
    }

    var body: some View {
        if tag == nil {
            ContentUnavailableView(
                "Select a tag",
                systemImage: "tag.slash",
                description: Text("Let's browse all photos.")
            )
        } else {
            Text(tag?.name ?? "Unknown Tag")
        }
    }
}
