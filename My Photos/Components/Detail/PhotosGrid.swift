import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    let sidebarSelection: SidebarItem?

    private var photos: [Photo] {
        switch sidebarSelection {
        case .tag(let tag):
            return tag.photos.sorted { $0.dateTaken > $1.dateTaken }
        default:
            return allPhotos
        }
    }
    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 200), spacing: 8)
    ]

    init(_ sidebarSelection: SidebarItem?) {
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
                PhotoCard(photo, variant: .detail)
                    .padding(16)
            }
        }
    }
}
