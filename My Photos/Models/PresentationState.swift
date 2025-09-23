import Observation
import SwiftUI

private struct PresentationStateFocusedKey: FocusedValueKey {
    typealias Value = Binding<PresentationState>
}

extension FocusedValues {
    var presentationState: Binding<PresentationState>? {
        get { self[PresentationStateFocusedKey.self] }
        set { self[PresentationStateFocusedKey.self] = newValue }
    }
}

@MainActor
@Observable
final class PresentationState {
    var photoFilter: Set<SidebarItem> = []
    var presentationMode: PresentationMode = .grid
    var showOnlySelected: Bool = false
    var isSelecting: Bool = false

    var selectedTags: [Tag] { photoFilter.selectedTags }
    var selectedFilters: [Filter] { photoFilter.selectedFilters }

    var canEditOrDeleteSelection: Bool { photoFilter.canEditOrDeleteSelection }
    var canEditSelection: Bool { photoFilter.canEditSelection }
    var canDeleteSelection: Bool { photoFilter.canDeleteSelection }
    var canDeleteManySelection: Bool { photoFilter.canDeleteManySelection }
}
