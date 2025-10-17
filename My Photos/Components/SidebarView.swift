import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Environment(PresentationState.self) private var state
    @State private var selection: Set<SidebarItem> = []

    var body: some View {
        List(selection: $selection) {
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
        .onChange(of: selection) {
            AppIntents.updatePhotoFilter(selection)
        }
        .toolbar {
            TagToolbar()
        }
    }
}
