import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Environment(PresentationState.self) private var state
    @State private var selection: Set<SidebarItem> = [.all]

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Photos").font(.title)
                Text("Showing \(state.photoSource.name.lowercased())")
                    .font(.subheadline)
            }
            Spacer()
        }.padding()

        List(selection: $selection) {
            Label(SidebarItem.all.name, systemImage: SidebarItem.all.icon)
                .tag(SidebarItem.all)

            DatesSection()
            PlacesSection()
            AlbumsSection()
            PeopleSection()
            EventsSection()
            TagsSection()
        }
        .listStyle(.sidebar)
        .onChange(of: selection) {
            withAnimation {
                if selection.contains(SidebarItem.all) {
                    selection = [.all]
                    state.photoFilter = []
                } else {
                    state.photoFilter = selection.filter { $0 != .all }
                }
            }
        }
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
        #endif
        .toolbar {
            TagToolbar()
        }.safeAreaBar(edge: .bottom) {
            SidebarFooter()
        }.padding(12)
    }
}
