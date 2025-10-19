import SwiftUI

struct FiltersSection: View {
    @State private var selection: Filter = .all
    
    var body: some View {
        Picker("", selection: $selection) {
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
        }.labelsHidden()
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .environment(\.controlSize, .large)
            .tint(.accentColor)
            .padding(.bottom, 12)
    }
}
