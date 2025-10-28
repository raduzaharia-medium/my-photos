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

        SidebarList(state: state)
    }
}

private struct SidebarList: View {
    @Bindable var state: PresentationState
    
    var body: some View {
        List(selection: $state.photoFilter) {
            DatesSection()
            PlacesSection()
            AlbumsSection()
            PeopleSection()
            EventsSection()
            TagsSection()
        }
        .listStyle(.sidebar)
        #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 300)
        #endif
        .toolbar {
            TagToolbar()
        }.safeAreaBar(edge: .bottom) {
            SidebarFooter(state: state)
        }.padding(12)
    }
}
