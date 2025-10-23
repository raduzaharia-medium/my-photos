import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Environment(PresentationState.self) private var state

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Photos").font(.title)
                Text("Showing \(state.photoSource.name.lowercased())")
                    .font(.subheadline)
            }
            Spacer()
        }.padding()

        List {
            DatesSection()
            PlacesSection()
            AlbumsSection()
            PeopleSection()
            EventsSection()
            TagsSection()
        }
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
        #endif
        .contextMenu(forSelectionType: SidebarItem.self) { items in
            SidebarContextMenu(items)
        }.toolbar {
            TagToolbar()
        }.safeAreaBar(edge: .bottom) {
            SidebarFooter()
        }.padding(12)
    }
}
