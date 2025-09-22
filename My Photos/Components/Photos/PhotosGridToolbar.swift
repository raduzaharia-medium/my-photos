import SwiftUI

struct PhotosGridToolbar: ToolbarContent {
    @Binding var isSelectionMode: Bool
    @Binding var selectedPhotos: Set<Photo>

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            HStack(spacing: 6) {
                Image(systemName: isSelectionMode ? "checkmark.circle.fill" : "checkmark.circle.badge.plus")
                    .help(isSelectionMode ? "Exit selection mode" : "Enter selection mode")

                Toggle(isOn: $isSelectionMode) { EmptyView() }
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .onChange(of: isSelectionMode) { _, newValue in
                        if !newValue {
                            selectedPhotos.removeAll()
                        }
                    }
            }
            .padding(.horizontal, 4)
        }
    }
}
