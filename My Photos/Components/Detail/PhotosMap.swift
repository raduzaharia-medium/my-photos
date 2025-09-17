import MapKit
import SwiftData
import SwiftUI

struct PhotosMap: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]
    @State private var camera: MapCameraPosition = .automatic

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

    init(_ sidebarSelection: Set<SidebarItem>) {
        self.sidebarSelection = sidebarSelection
    }

    var body: some View {
        Map(position: $camera) {
            ForEach(photos) { photo in
                Annotation("",
                    coordinate: CLLocationCoordinate2D(
                        latitude: photo.location.latitude,
                        longitude: photo.location.longitude
                    )
                ) {
                    PhotoCard(photo, variant: .pin)
                }
            }
        }
    }
}
