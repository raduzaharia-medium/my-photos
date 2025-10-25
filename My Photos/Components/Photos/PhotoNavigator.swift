import SwiftUI

struct PhotoNavigator: View {
    @State private var index: Int

    let photos: [Photo]

    private var currentPhoto: Photo { photos[index] }

    init(_ photos: [Photo], index: Int) {
        self.photos = photos
        self.index = index
    }

    var body: some View {
        VStack(spacing: 0) {
            PhotoCard(currentPhoto, variant: .detail)
                .padding(16)
                .animation(.default, value: currentPhoto.id)
        }
        .focusable()
        .toolbar { PhotoNavigatorToolbar(photos, index: $index) }
        .toolbarBackground(.hidden, for: .automatic)
        .navigationTitle(Text(currentPhoto.title))
    }
}
