import SwiftUI

struct PhotoNavigatorToolbar: ToolbarContent {
    var index: Int
    var count: Int
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {
                AppIntents.navigateToPreviousPhoto()
            }) {
                Image(systemName: "chevron.left")
            }
            .help("Previous photo")
            .disabled(index <= 0)
            .keyboardShortcut(.leftArrow, modifiers: [])

            Button(action: {
                AppIntents.navigateToNextPhoto()
            }) {
                Image(systemName: "chevron.right")
            }
            .help("Next photo")
            .disabled(index + 1 >= count)
            .keyboardShortcut(.rightArrow, modifiers: [])
        }
    }
}
