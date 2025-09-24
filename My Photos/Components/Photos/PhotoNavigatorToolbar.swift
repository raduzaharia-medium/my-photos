import SwiftUI

struct PhotoNavigatorToolbar: ToolbarContent {
    @Environment(PresentationState.self) private var presentationState

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {
                AppIntents.navigateToPreviousPhoto()
            }) {
                Image(systemName: "chevron.left")
            }
            .help("Previous photo")
            .disabled(presentationState.currentPhotoIndex ?? 0 <= 0)
            .keyboardShortcut(.leftArrow, modifiers: [])

            Button(action: {
                AppIntents.navigateToNextPhoto()
            }) {
                Image(systemName: "chevron.right")
            }
            .help("Next photo")
            .disabled(
                presentationState.currentPhotoIndex ?? 0
                    >= presentationState.filteredPhotos.count - 1
            )
            .keyboardShortcut(.rightArrow, modifiers: [])
        }
    }
}
