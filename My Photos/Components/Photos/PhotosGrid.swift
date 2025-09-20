import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    let sidebarSelection: Set<SidebarItem>

    private var photos: [Photo] {
        allPhotos.filtered(by: sidebarSelection)
    }
    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    init(_ sidebarSelection: Set<SidebarItem>) {
        self.sidebarSelection = sidebarSelection
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(photos) { photo in
                        NavigationLink(value: photo) {
                            PhotoCard(photo, variant: .grid)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.all)
            }
            .navigationDestination(for: Photo.self) { photo in
                let index = photos.firstIndex(of: photo) ?? 0
                PhotoNavigator(photos: photos, index: index)
            }
        }
    }
}
