import MapKit
import SwiftData
import SwiftUI

struct PhotosMap: View {
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]
    @State private var camera: MapCameraPosition = .automatic

    let selectedItem: SidebarItem?

    private var photos: [Photo] {
        switch selectedItem {
        case .tag(let tag):
            return tag.photos.sorted { $0.dateTaken > $1.dateTaken }
        default:
            return allPhotos
        }
    }

    init(_ selectedItem: SidebarItem?) {
        self.selectedItem = selectedItem
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
                    PhotoPin(photo)
                }
            }
        }
    }
}
