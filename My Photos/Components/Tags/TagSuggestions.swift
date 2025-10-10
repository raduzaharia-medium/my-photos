import SwiftUI

struct TagSuggestions: View {
    @Environment(TagPickerState.self) private var tagPickerState

    private var kind: TagKind
    private var onSelect: ((Tag) -> Void)?

    private var suggestions: [Tag] { tagPickerState.suggestions[kind] ?? [] }
    private var selectedIndex: Int? {
        tagPickerState.selectedIndex[kind] ?? nil
    }

    init(_ tagKind: TagKind, onSelect: ((Tag) -> Void)? = nil) {
        self.kind = tagKind
        self.onSelect = onSelect
    }

    var body: some View {
        return VStack(alignment: .leading, spacing: 8) {
            Text("Suggestions")
                .font(.caption)
                .foregroundStyle(.secondary)

            if suggestions.isEmpty {
                Text("No matching tags")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(suggestions.indices, id: \.self) { index in
                    let tag = suggestions[index]
                    let isHighlighted = index == selectedIndex

                    Button {
                        onSelect?(tag)
                    } label: {
                        Label(tag.name, systemImage: tag.kind.icon)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(
                                isHighlighted
                                    ? Color.accentColor.opacity(0.15)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
