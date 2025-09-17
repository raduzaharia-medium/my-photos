import SwiftData
import SwiftUI

struct PhotosGrid: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]

    let sidebarSelection: Set<SidebarItem>

    private var photos: [Photo] {
        let selectedTags: [Tag] = sidebarSelection.compactMap { selection in
            if case .tag(let t) = selection { return t }
            return nil
        }

        guard !selectedTags.isEmpty else {
            return allPhotos
        }

        let filtered = allPhotos.filter { photo in
            photo.tags.contains { tag in
                selectedTags.contains(where: { $0 == tag })
            }
        }

        return filtered.sorted { $0.dateTaken > $1.dateTaken }
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
