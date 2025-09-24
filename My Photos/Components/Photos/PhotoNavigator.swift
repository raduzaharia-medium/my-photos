import SwiftUI

struct PhotoNavigator: View {
    @Environment(PresentationState.self) private var presentationState

    let photos: [Photo]

    init(photos: [Photo]) {
        self.photos = photos
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let currentPhoto = presentationState.currentPhoto,
                    photos.contains(currentPhoto)
                {
                    PhotoCard(currentPhoto, variant: .detail)
                        .padding(16)
                        .animation(.default, value: currentPhoto.id)
                } else {
                    Text("No photo")
                        .padding(32)
                }
            }
        }
        .focusable()
        .toolbar {
            PhotoNavigatorToolbar(photos)
        }
        .toolbarBackground(.hidden, for: .automatic)
        .navigationTitle(
            Text(presentationState.currentPhoto?.title ?? "No photo")
        )
        .setupPhotoNavigationHandlers(
            presentationState: presentationState,
            photos: photos,
        )
    }
}
