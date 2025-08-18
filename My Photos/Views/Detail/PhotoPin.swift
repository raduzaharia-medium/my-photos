import SwiftUI

struct PhotoPin: View {
    let photo: Photo
    
    init(_ photo: Photo) {
        self.photo = photo
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.15), radius: 2)
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
