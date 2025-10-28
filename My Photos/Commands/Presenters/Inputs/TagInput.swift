import SwiftData
import SwiftUI

struct TagInput: View {
    @Query(sort: [SortDescriptor(\Tag.key)]) private var tags: [Tag]
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""
    @Binding var selection: Set<Tag>

    private var selectionArray: [Tag] { Array(selection) }
    private var filteredTags: [Tag] {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return tags }

        return tags.filter { $0.name.localizedCaseInsensitiveContains(term) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.caption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8, lineSpacing: 4) {
                ForEach(selectionArray, id: \.self) {
                    tag in
                    SidebarItemChip(
                        item: .tag(tag),
                        onRemove: { selection.remove(tag) }
                    )
                }

                TextField("", text: $searchText)
                    .padding(.leading, selection.isEmpty ? 6 : 0)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    #if os(macOS) || os(iPadOS)
                        .textInputSuggestions {
                            if searchText.count > 1 {
                                ForEach(filteredTags) { tag in
                                    Label(tag.name, systemImage: Tag.icon)
                                    .textInputCompletion(tag.name)
                                }
                            }
                        }
                    #endif
                    .onSubmit {
                        if let first = filteredTags.first {
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
