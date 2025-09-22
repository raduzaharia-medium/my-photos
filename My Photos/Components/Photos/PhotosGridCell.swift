import SwiftUI

struct PhotosGridCell: View {
    let photo: Photo
    let isSelectionMode: Bool
    let isSelected: Binding<Bool>

    init(photo: Photo, isSelectionMode: Bool, isSelected: Binding<Bool>) {
        self.photo = photo
        self.isSelectionMode = isSelectionMode
        self.isSelected = isSelected
    }

    var body: some View {
        if isSelectionMode {
            PhotoCard(photo, variant: .selectable, isSelected: isSelected)
        } else {
            NavigationLink(value: photo) {
                PhotoCard(photo, variant: .grid)
            }
        }
    }
}
