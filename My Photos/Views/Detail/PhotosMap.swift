import MapKit
import SwiftData
import SwiftUI

struct PhotosMap: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]
    @State private var camera: MapCameraPosition = .automatic

    let sidebarSelection: SidebarItem?

    private var photos: [Photo] {
        switch sidebarSelection {
        case .tag(let tag):
            return tag.photos.sorted { $0.dateTaken > $1.dateTaken }
        default:
            return allPhotos
        }
    }

    init(_ sidebarSelection: SidebarItem?) {
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
