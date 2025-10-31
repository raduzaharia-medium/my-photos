import MapKit
import SwiftUI

struct PhotosMap: View {
    @State private var camera: MapCameraPosition = .automatic

    let photos: [Photo]
    
    var body: some View {
        Map(position: $camera) {
            ForEach(photos) { photo in
                if let loc = photo.location {
                    Annotation("",
                        coordinate: CLLocationCoordinate2D(
                            latitude: loc.latitude,
                            longitude: loc.longitude
                        )
                    ) {
                        Text(photo.key)
                       // PhotoCard(photo, variant: .pin)
                    }
                }
            }
        }
    }
}
