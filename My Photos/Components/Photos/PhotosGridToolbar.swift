import SwiftUI

struct PhotosGridToolbar: ToolbarContent {
    @Environment(PresentationState.self) private var presentationState
    @Binding var selectedPhotos: Set<Photo>

    var body: some ToolbarContent {
        @Bindable var presentation = presentationState
        
        ToolbarItemGroup(placement: .primaryAction) {
            HStack(spacing: 6) {
                Image(
                    systemName: presentationState.isSelecting
                        ? "checkmark.circle.fill"
                        : "checkmark.circle.badge.plus"
                )
                .help(
                    presentationState.isSelecting
                        ? "Exit selection mode" : "Enter selection mode"
                )

                Toggle(isOn: $presentation.isSelecting) { EmptyView() }
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .onChange(of: presentationState.isSelecting) { _, newValue in
                        if !newValue {
                            selectedPhotos.removeAll()
                        }
                    }
            }
            .padding(.horizontal, 4)
        }
    }
}
