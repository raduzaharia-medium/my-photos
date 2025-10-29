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
            AppIntents.requestTagPhotos(Array(state.photoSelection))
        } label: {
            Image(systemName: "tag")
        }.controlSize(.regular)
            .disabled(!allowTagging)

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
