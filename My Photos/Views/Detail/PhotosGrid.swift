import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    let selectedItem: SidebarItem?

    private var photos: [Photo] {
        switch selectedItem {
        case .tag(let tag):
            return tag.photos.sorted { $0.dateTaken > $1.dateTaken }
        default:
            return allPhotos
        }
    }
    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    init(_ selectedItem: SidebarItem?) {
        self.selectedItem = selectedItem
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(photos) { photo in
                    Text("Something")
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(selectedItem?.name ?? "All Photos")
    }
}
