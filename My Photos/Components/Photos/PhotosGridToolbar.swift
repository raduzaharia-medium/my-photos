import SwiftUI

struct PhotosGridToolbar: ToolbarContent {
    @Environment(PresentationState.self) private var state

    let photos: [Photo]

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            #if os(iOS)
                if state.photoSelectionMode {
                    MainButtons(photos: photos)
                }
            #else
                MainButtons(photos: photos)
            #endif
        }

        #if os(iOS)
            if state.photoSelectionMode {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", role: .cancel) {
                        PhotoIntents.clearSelection()
                        PhotoIntents.disableSelectionMode()
                    }
                    .accessibilityIdentifier("Done")
                    .keyboardShortcut(.cancelAction)
                    .tint(.accentColor)
                }
            }
        #endif
    }
}

private struct MainButtons: View {
    @Environment(PresentationState.self) private var state

    let photos: [Photo]

    var allowTagging: Bool { !state.photoSelection.isEmpty }
    var allSelected: Bool { state.photoSelection.count == photos.count }
    var selectionIcon: String {
        allSelected ? "checkmark.circle.fill" : "checkmark.circle"
    }

    var body: some View {
        Button {
            PhotoIntents.requestChangeDate()
        } label: {
            Image(systemName: DateTaken.icon)
        }.controlSize(.regular).disabled(!allowTagging)

        Button {
            PhotoIntents.requestChangeLocation()
        } label: {
            Image(systemName: Place.icon)
        }.controlSize(.regular).disabled(!allowTagging)
        
        Button {
            PhotoIntents.requestChangeAlbum()
        } label: {
            Image(systemName: Album.icon)
        }.controlSize(.regular).disabled(!allowTagging)
        
        Button {
            // TODO: PhotoIntents.requestDetectFaces(Array(state.photoSelection))
        } label: {
            Image(systemName: Person.icon)
        }.controlSize(.regular).disabled(!allowTagging)

        Button {
            PhotoIntents.requestChangeEvent()
        } label: {
            Image(systemName: Event.icon)
        }.controlSize(.regular).disabled(!allowTagging)
        
        Button {
            PhotoIntents.requestTag(Array(state.photoSelection))
        } label: {
            Image(systemName: Tag.icon)
        }.controlSize(.regular).disabled(!allowTagging)
        
        Button {
            if allSelected {
                PhotoIntents.clearSelection()
            } else {
                PhotoIntents.select(photos)
            }
        } label: {
            Image(systemName: selectionIcon)
        }.controlSize(.regular)
    }
}
