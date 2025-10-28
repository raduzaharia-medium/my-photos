import SwiftUI

struct SidebarFooter: View {
    @Bindable var state: PresentationState

    var body: some View {
        HStack {
            if !state.photoFilter.isEmpty || state.photoSource != .all {
                Button {
                    withAnimation {
                        state.photoSource = .all
                        state.photoFilter = []
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                }.buttonStyle(.borderless)
                    .help("Reset filters")
            }

            Picker("", selection: $state.photoSource) {
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

                if !state.photoSelection.isEmpty {
                    Image(systemName: Filter.selected.icon)
                        .accessibilityLabel(Text(Filter.selected.name))
                        .tag(Filter.selected)
                        .help(Text("Show only selected photos"))
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.default, value: state.photoSelection)
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .animation(.default, value: state.photoFilter)
        .animation(.default, value: state.photoSource)
        .animation(.default, value: state.photoSelection)
    }
}

