import SwiftData
import SwiftUI

struct AlbumInput: View {
    @Query(sort: [SortDescriptor(\Album.key)]) private var albums: [Album]
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""
    @Binding var selection: Set<Album>

    private var selectionArray: [Album] { Array(selection) }
    private var filteredAlbums: [Album] {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return albums }

        return albums.filter { $0.name.localizedCaseInsensitiveContains(term) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Albums")
                .font(.caption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8, lineSpacing: 4) {
                ForEach(selectionArray, id: \.self) {
                    album in
                    SidebarItemChip(
                        item: .album(album),
                        onRemove: { selection.remove(album) }
                    )
                }

                TextField("", text: $searchText)
                    .padding(.leading, selection.isEmpty ? 6 : 0)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    #if os(macOS) || os(iPadOS)
                        .textInputSuggestions {
                            if searchText.count > 1 {
                                ForEach(filteredAlbums) { album in
                                    Label(album.name, systemImage: Album.icon)
                                    .textInputCompletion(album.name)
                                }
                            }
                        }
                    #endif
                    .onSubmit {
                        if let first = filteredAlbums.first {
                            selection.insert(first)
                        }
                        searchText = ""
                    }
            }
            .contentShape(Rectangle())
            .onTapGesture { isTextFieldFocused = true }
            // TODO: make the TextField have full width
            .cursorIBeamIfAvailable()
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
    }
}
