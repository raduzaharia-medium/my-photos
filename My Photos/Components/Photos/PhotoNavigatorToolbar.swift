import SwiftUI

struct PhotoNavigatorToolbar: ToolbarContent {
    @Binding private var index: Int
    
    let photos: [Photo]
    
    init(_ photos: [Photo], index: Binding<Int>) {
        self.photos = photos
        self._index = index
    }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button(action: {
                guard index > 0 else { return }
                index -= 1
            }) {
                Image(systemName: "chevron.left")
            }
            .help("Previous photo")
            .disabled(index <= 0)
            .keyboardShortcut(.leftArrow, modifiers: [])

            Button(action: {
                guard index < photos.count - 1 else { return }
                index += 1
            }) {
                Image(systemName: "chevron.right")
            }
            .help("Next photo")
            .disabled(index >= photos.count - 1)
            .keyboardShortcut(.rightArrow, modifiers: [])
        }
    }
}
