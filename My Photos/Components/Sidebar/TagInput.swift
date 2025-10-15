import SwiftUI

struct TagInput: View {
    @Environment(TagPickerState.self) private var tagPickerState
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""

    private var tags: Set<Tag> { tagPickerState.tags[kind] ?? [] }
    private var tagArray: [Tag] { Array(tags) }

    let title: String
    let kind: TagKind

    init(_ title: String, kind: TagKind) {
        self.title = title
        self.kind = kind
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
                        AppIntents.loadTagSuggestions(kind, searchText)
                    }
                    .onSubmit {
                        AppIntents.addSelectedTagToEditor(kind)
                        searchText = ""
                    }
                    .arrowKeyNavigation(
                        onUp: { AppIntents.selectPreviousTagSuggestion(kind) },
                        onDown: { AppIntents.selectNextTagSuggestion(kind) },
                        onReturn: {
                            AppIntents.addSelectedTagToEditor(kind)
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
                TagSuggestions(kind) { tag in
                    AppIntents.addTagToEditor(tag)
                    searchText = ""
                }
            }
        }
    }
}
