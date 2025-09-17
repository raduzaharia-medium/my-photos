import MapKit
import SwiftData
import SwiftUI

struct PhotosMap: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]
    @State private var camera: MapCameraPosition = .automatic

    let sidebarSelection: Set<SidebarItem>

    private var photos: [Photo] {
        allPhotos.filtered(by: sidebarSelection)
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
