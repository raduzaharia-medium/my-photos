import SwiftUI

struct PhotosGridToolbar: ToolbarContent {
    @Environment(PresentationState.self) private var state

    let photos: [Photo]

    var allowTagging: Bool { !state.photoSelection.isEmpty }
    var allSelected: Bool { state.photoSelection.count == photos.count }
    var selectionIcon: String {
        allSelected ? "checkmark.circle.fill" : "checkmark.circle"
    }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                AppIntents.requestTagPhotos(Array(state.photoSelection))
            } label: {
                Image(systemName: "tag")
            }.controlSize(.regular)
                .disabled(!allowTagging)

            Button {
                AppIntents.toggleSelectAllPhotos()
            } label: {
                Image(systemName: selectionIcon)
            }.controlSize(.regular)
        }
    }
}
