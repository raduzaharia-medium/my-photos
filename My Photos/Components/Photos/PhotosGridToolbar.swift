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

        ToolbarItemGroup(placement: .primaryAction) {
            HStack(spacing: 6) {
                if presentationState.isSelecting {
                    Button {
                        AppIntents.requestTagPhotos()
                    } label: {
                        Image(systemName: "tag")
                    }.controlSize(.regular)
                        .disabled(presentationState.selectedPhotos.isEmpty)

                    Button {

                    } label: {
                        Image(
                            systemName: presentationState.isSelecting
                                ? "checkmark.circle.fill"
                                : "checkmark.circle"
                        )
                    }.controlSize(.regular)
                    
                    Spacer()
                }
                
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
