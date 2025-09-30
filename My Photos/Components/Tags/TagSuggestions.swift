import SwiftUI

struct TagSuggestions: View {
    @Environment(PresentationState.self) private var presentationState

    private var searchText: Binding<String>
    private var onSelect: ((Tag) -> Void)?

    private var allTags: [Tag] {
        presentationState.tags.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name)
                == .orderedAscending
        }
    }
    private var filteredTags: [Tag] {
        if searchText.wrappedValue.isEmpty { return allTags }
        return allTags.filter {
            $0.name.localizedCaseInsensitiveContains(searchText.wrappedValue)
        }
    }

    init(_ searchText: Binding<String>, onSelect: ((Tag) -> Void)? = nil) {
        self.searchText = searchText
        self.onSelect = onSelect
    }

    var body: some View {
        let matches = filteredTags.filter {
            $0.name.lowercased().contains(searchText.wrappedValue.lowercased())
        }

        return Section("Suggestions") {
            if matches.isEmpty {
                Text("No matching tags")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(matches) { tag in
                    Button {
                        if let onSelect {
                            onSelect(tag)
                        } else {
                            searchText.wrappedValue = tag.name
                        }
                    } label: {
                        Label(tag.name, systemImage: tag.kind.icon)
                    }
                }
            }
        }
    }
}

