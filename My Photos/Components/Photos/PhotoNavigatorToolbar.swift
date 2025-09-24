import SwiftUI

struct PhotoNavigatorToolbar: ToolbarContent {
    @Environment(PresentationState.self) private var presentationState

    let photos: [Photo]

    init(_ photos: [Photo]) {
        self.photos = photos
    }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {
                AppIntents.navigateToPreviousPhoto()
            }) {
                Image(systemName: "chevron.left")
            }
            .help("Previous photo")
            .disabled(presentationState.getCurrentPhotoIndex(photos) ?? 0 <= 0)
            .keyboardShortcut(.leftArrow, modifiers: [])

            Button(action: {
                AppIntents.navigateToNextPhoto()
            }) {
                Image(systemName: "chevron.right")
            }
            .help("Next photo")
            .disabled(
                presentationState.getCurrentPhotoIndex(photos) ?? 0
                    >= presentationState.getFilteredPhotos(photos).count - 1
            )
            .keyboardShortcut(.rightArrow, modifiers: [])
        }
    }
}
