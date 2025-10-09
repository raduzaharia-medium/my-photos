import SwiftUI

struct TagInput: View {
    @Environment(PresentationState.self) private var presentationState
    @Environment(TagPickerState.self) private var tagPickerState
    @FocusState private var isTextFieldFocused: Bool

    let title: String
    let kind: TagKind

    var suggestions: [Tag] {
        return presentationState.getTags(
            searchText: tagPickerState.searchText[kind] ?? "",
            kind: kind
        )
    }

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
                ForEach(Array(tagPickerState.tags[kind] ?? []), id: \.self) { tag in
                    TagChip(
                        tag: tag,
                        onRemove: { tagPickerState.removeTag(tag) }
                    )
                }

                TextField("", text: Binding(
                    get: { tagPickerState.searchText[kind] ?? "" },
                    set: { tagPickerState.searchText[kind] = $0 }
                ))
                    .padding(
                        .leading,
                        tagPickerState.tags[kind]?.isEmpty ?? true ? 6 : 0
                    )
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    .onSubmit { tagPickerState.addSelection(kind, suggestions) }
                    .arrowKeyNavigation(
                        onUp: {
                            tagPickerState.selectPrevious(kind, suggestions.count)
                        },
                        onDown: {
                            tagPickerState.selectNext(kind, suggestions.count)
                        },
                        onReturn: {
                            tagPickerState.addSelection(kind, suggestions)
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

            if !(tagPickerState.searchText[kind] ?? "").isEmpty {
                TagSuggestions(
                    suggestions: suggestions,
                    highlightedIndex: Binding<Int?>(
                        get: { tagPickerState.selectedIndex[kind] ?? nil },
                        set: { tagPickerState.selectedIndex[kind] = $0 }
                    )
                ) { tag in
                    tagPickerState.addTag(tag)
                }
            }
        }
    }
}
