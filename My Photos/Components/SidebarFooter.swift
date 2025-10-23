import SwiftUI

struct SidebarFooter: View {
    @Environment(PresentationState.self) private var state
    @State private var photoSource: Filter = .all

    var body: some View {
        HStack {
            if !state.photoFilter.isEmpty {
                Button {
                    withAnimation {
                        photoSource = .all
                        state.photoFilter = []
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                }.buttonStyle(.borderless).help("Reset filters")
            }

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

                if state.isSelecting == true {
                    Image(systemName: Filter.selected.icon)
                        .accessibilityLabel(Text(Filter.selected.name))
                        .tag(Filter.selected)
                        .help(Text("Show only selected photos"))
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .onChange(of: photoSource) {
                withAnimation {
                    state.photoSource = photoSource
                }
            }
        }
    }
}
