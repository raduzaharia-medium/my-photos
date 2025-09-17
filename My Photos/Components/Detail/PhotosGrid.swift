import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    let sidebarSelection: Set<SidebarItem>

    private var photos: [Photo] {
        if let tag = sidebarSelection.compactMap({ selection -> Tag? in
            if case .tag(let t) = selection { return t }
            return nil
        }).first {
            return tag.photos.sorted { $0.dateTaken > $1.dateTaken }
        } else {
            return allPhotos
        }
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
                PhotoCard(photo, variant: .detail)
                    .padding(16)
            }
        }
    }
}

