import SwiftUI

struct DetailViewToolbar: ToolbarContent {
    @Binding var isSelectionMode: Bool
    @Binding var selectionCategory: SelectionCategory
    @Binding var presentationMode: PresentationMode

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            if isSelectionMode {
                Picker("Selection", selection: $selectionCategory) {
                    ForEach(SelectionCategory.allCases) { c in
                        Text(c.rawValue).tag(c)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .help("Filter by All or Selected while in selection mode")
            } else {
                Picker("Tab", selection: $presentationMode) {
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
