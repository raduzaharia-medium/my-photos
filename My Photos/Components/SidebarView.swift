import SwiftUI
import UniformTypeIdentifiers

struct SidebarView: View {
    @Environment(PresentationState.self) private var state

    var body: some View {
        #if os(macOS) || os(iPadOS)
            HStack {
                VStack(alignment: .leading) {
                    Text("Photos").font(.title)
                    Text("Showing \(state.photoSource.name.lowercased())")
                        .font(.subheadline)
                }
                Spacer()
            }.padding()
        #endif

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
        .toolbar { TagToolbar() }
        #if os(macOS) || os(iPadOS)
            .safeAreaBar(edge: .bottom) {
                SidebarFooter(state: state).padding(12)
            }
        #endif
        #if os(iOS)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        #endif
    }
}
