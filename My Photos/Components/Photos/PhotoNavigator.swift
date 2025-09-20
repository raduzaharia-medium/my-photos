import SwiftUI

struct PhotoNavigator: View {
    @State private var index: Int
    let photos: [Photo]

    init(photos: [Photo], index: Int) {
        self.photos = photos
        _index = State(initialValue: index)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if photos.indices.contains(index) {
                    PhotoCard(photos[index], variant: .detail)
                        .padding(16)
                        .animation(.default, value: index)
                } else {
                    Text("No photo")
                        .padding(32)
                }
            }
        }
        .focusable()
        .toolbar {
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
                .disabled(index + 1 >= photos.count)
                .keyboardShortcut(.rightArrow, modifiers: [])
            }
        }
        .setupPhotoNavigationHandlers(
            index: $index,
            count: photos.count
        )
    }
}
