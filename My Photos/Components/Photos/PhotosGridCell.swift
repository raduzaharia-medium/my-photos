import SwiftUI

struct PhotosGridCell: View {
    @Environment(PresentationState.self) private var presentationState
    
    let photo: Photo
    let isSelected: Binding<Bool>

    init(photo: Photo, isSelected: Binding<Bool>) {
        self.photo = photo
        self.isSelected = isSelected
    }

    var body: some View {
        if presentationState.isSelecting {
            PhotoCard(photo, variant: .selectable, isSelected: isSelected)
        } else {
            NavigationLink(value: photo) {
                PhotoCard(photo, variant: .grid)
            }
        }
    }
}
