import MapKit
import SwiftData
import SwiftUI

struct PhotosMap: View {
    @Environment(PresentationState.self) private var presentationState
    @Query(sort: \Photo.dateTaken, order: .reverse) private var allPhotos:
        [Photo]
    @State private var camera: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $camera) {
            ForEach(presentationState.filteredPhotos) { photo in
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
        .onAppear() {
            AppIntents.updatePhotos(allPhotos)
        }
    }
}
