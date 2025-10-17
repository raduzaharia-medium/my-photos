import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Environment(PresentationState.self) private var state

    private var selectionBinding: Binding<Set<SidebarItem>> {
        Binding(
            get: { state.photoFilter },
            set: { newValue in
                AppIntents.updatePhotoFilter(newValue)
            }
        )
    }

    var body: some View {
        List(selection: selectionBinding) {
            FiltersSection()
            DatesSection()
            PlacesSection()
            AlbumsSection()
            PeopleSection()
            EventsSection()
            TagsSection()
        }
        .task {
            AppIntents.resetPhotoFilter()
        }
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
        #endif
        .contextMenu(forSelectionType: SidebarItem.self) { items in
            SidebarContextMenu(items)
        }
        .toolbar {
            TagToolbar()
        }
    }
}
