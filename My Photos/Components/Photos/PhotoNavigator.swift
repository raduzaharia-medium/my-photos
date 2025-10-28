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
        #if os(macOS)
            DesktopNavigator(
                index: $index,
                currentPhoto: currentPhoto,
                photos: photos
            )
        #endif
        #if os(iOS) || os(iPadOS)
            MobileNavigator(
                index: $index,
                currentPhoto: currentPhoto,
                photos: photos
            )
        #endif
    }
}

struct DesktopNavigator: View {
    @Binding var index: Int
    let currentPhoto: Photo
    let photos: [Photo]

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

struct MobileNavigator: View {
    @Binding var index: Int
    let currentPhoto: Photo
    let photos: [Photo]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $index) {
                ForEach(Array(photos.enumerated()), id: \.offset) { i, photo in
                    PhotoCard(photo, variant: .detail)
                        .padding(16)
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.default, value: index)
        }
        .focusable()
        .toolbarBackground(.hidden, for: .automatic)
        .navigationTitle(Text(currentPhoto.title))
    }
}
