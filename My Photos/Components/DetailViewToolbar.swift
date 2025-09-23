import SwiftUI

struct DetailViewToolbar: ToolbarContent {
    @Environment(PresentationState.self) private var presentationState

    var body: some ToolbarContent {
        let presentationModeBinding = Binding<PresentationMode>(
            get: { presentationState.presentationMode },
            set: { newMode in
                guard newMode != presentationState.presentationMode else {
                    return
                }
                AppIntents.togglePresentationMode()
            }
        )
        let selectionFilterBinding = Binding<Bool>(
            get: { presentationState.showOnlySelected },
            set: { newMode in
                guard newMode != presentationState.showOnlySelected else {
                    return
                }
                AppIntents.toggleSelectionFilter()
            }
        )

        ToolbarItem(placement: .principal) {
            if presentationState.isSelecting {
                Picker("ShowOnlySelected", selection: selectionFilterBinding) {
                    Text("All").tag(false)
                    Text("Selected").tag(true)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .help("Filter by All or Selected while in selection mode")
            } else {
                Picker("PresentationMode", selection: presentationModeBinding) {
                    Text("Grid").tag(PresentationMode.grid)
                    Text("Map").tag(PresentationMode.map)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .help("Change how this collection is displayed")
            }
        }
    }
}
