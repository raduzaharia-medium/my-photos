import SwiftUI

struct DetailViewToolbar: ToolbarContent {
    @Environment(PresentationState.self) private var presentationState

    var body: some ToolbarContent {
        @Bindable var presentation = presentationState

        ToolbarItem(placement: .principal) {
            if presentationState.isSelecting {
                Picker("Selection", selection: $presentation.showOnlySelected) {
                    Text("All").tag(false)
                    Text("Selected").tag(true)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .help("Filter by All or Selected while in selection mode")
            } else {
                Picker("Tab", selection: $presentation.presentationMode) {
                    ForEach(PresentationMode.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .help("Change how this collection is displayed")
            }
        }
    }
}
