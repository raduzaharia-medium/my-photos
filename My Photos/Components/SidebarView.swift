import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Environment(PresentationState.self) private var state
    @State private var selection: Set<SidebarItem> = []
    @State private var photoSource: Filter = Filter.all

    var body: some View {
        List(selection: $selection) {
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
        }.onAppear {
            selection = [SidebarItem.filter(.all)]
        }.onChange(of: selection) {
            withAnimation {
                state.photoFilter = selection
            }
        }.safeAreaBar(edge: .bottom) {
            Picker("", selection: $photoSource) {
                Image(systemName: Filter.all.icon)
                    .accessibilityLabel(Text(Filter.all.name))
                    .tag(Filter.all)
                    .help(Text("Show all photos"))

                Image(systemName: Filter.favorites.icon)
                    .accessibilityLabel(Text(Filter.favorites.name))
                    .tag(Filter.favorites)
                    .help(Text("Show only favorite photos"))

                Image(systemName: Filter.recent.icon)
                    .accessibilityLabel(Text(Filter.recent.name))
                    .tag(Filter.recent)
                    .help(Text("Show only recently taken photos"))

                Image(systemName: Filter.edited.icon)
                    .accessibilityLabel(Text(Filter.edited.name))
                    .tag(Filter.edited)
                    .help(Text("Show only edited photos"))
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }.padding(12)
    }
}
