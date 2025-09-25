import MapKit
import SwiftUI

struct PhotosMap: View {
    @Environment(PresentationState.self) private var presentationState
    @State private var camera: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $camera) {
            ForEach(presentationState.filteredPhotos) { photo in
                if let loc = photo.location {
                    Annotation("",
                        coordinate: CLLocationCoordinate2D(
                            latitude: loc.latitude,
                            longitude: loc.longitude
                        )
                    ) {
                        PhotoCard(photo, variant: .pin)
                    }
                }
            }
        }
    }
}
