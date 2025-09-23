import MapKit
import SwiftData
import SwiftUI

struct PhotosMap: View {
    @Environment(PresentationState.self) private var presentationState
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]
    @State private var camera: MapCameraPosition = .automatic

    private var photos: [Photo] {
        allPhotos.filtered(by: presentationState.photoFilter)
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
