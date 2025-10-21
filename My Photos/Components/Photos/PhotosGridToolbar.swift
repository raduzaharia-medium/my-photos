import SwiftUI

struct PhotosGridToolbar: ToolbarContent {
    @Environment(PresentationState.self) private var presentationState

    var body: some ToolbarContent {
        @Bindable var presentation = presentationState

        let isSelectingBinding = Binding<Bool>(
            get: { presentationState.isSelecting },
            set: { newMode in
                guard newMode != presentationState.isSelecting else { return }
                AppIntents.toggleSelectionMode()
            }
        )

        if presentationState.isSelecting {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    AppIntents.requestTagPhotos()
                } label: {
                    Image(systemName: "tag")
                }.controlSize(.regular)
                    .disabled(
                        presentationState.selectedPhotos.isEmpty
                            && !presentationState.allPhotosSelected
                    )

                Button {
                    AppIntents.toggleSelectAllPhotos()
                } label: {
                    Image(
                        systemName: presentationState.allPhotosSelected
                            ? "checkmark.circle.fill"
                            : "checkmark.circle"
                    )
                }.controlSize(.regular)
            }
        }

        ToolbarSpacer(.fixed)

        ToolbarItemGroup(placement: .primaryAction) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.badge.plus")
                    .help(
                        presentationState.isSelecting
                            ? "Exit selection mode" : "Enter selection mode"
                    )

                Toggle(isOn: isSelectingBinding) { EmptyView() }
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
            .padding(.horizontal, 4)
        }
    }
}
