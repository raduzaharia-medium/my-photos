import SwiftUI

struct PhotoCard: View {
    let photo: Photo

    init(_ photo: Photo) {
        self.photo = photo
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
        }.overlay {
            Text(photo.title)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .padding(4)

        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
    }
}
