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
            PhotoNavigatorToolbar(index: index, count: photos.count)
        }
        .toolbarBackground(.hidden, for: .automatic)
        .navigationTitle(Text(photos[index].title))
        .setupPhotoNavigationHandlers(
            index: $index,
            count: photos.count
        )
    }
}
