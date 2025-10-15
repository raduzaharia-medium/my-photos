import SwiftUI

struct TagInput: View {
    @Environment(TagPickerState.self) private var tagPickerState
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""

    private var tags: Set<Tag> { tagPickerState.tags }
    private var tagArray: [Tag] { Array(tags) }

    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8, lineSpacing: 4) {
                ForEach(tagArray, id: \.self) {
                    tag in
                    TagChip(
                        tag: tag,
                        onRemove: { AppIntents.removeTagFromEditor(tag) }
                    )
                }

                TextField("", text: $searchText)
                    .padding(.leading, tags.isEmpty ? 6 : 0)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    .onChange(of: searchText, initial: false) {
                        AppIntents.loadTagSuggestions(searchText)
                    }
                    .onSubmit {
                        AppIntents.addSelectedTagToEditor()
                        searchText = ""
                    }
                    .arrowKeyNavigation(
                        onUp: { AppIntents.selectPreviousTagSuggestion() },
                        onDown: { AppIntents.selectNextTagSuggestion() },
                        onReturn: {
                            AppIntents.addSelectedTagToEditor()
                            searchText = ""
                        }
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture { isTextFieldFocused = true }
            .cursorIBeamIfAvailable()
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.quaternary, lineWidth: 1)
            )

            if !searchText.isEmpty {
                TagSuggestions() { tag in
                    AppIntents.addTagToEditor(tag)
                    searchText = ""
                }
            }
        }
    }
}
