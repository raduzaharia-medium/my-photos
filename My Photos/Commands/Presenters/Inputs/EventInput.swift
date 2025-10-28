import SwiftData
import SwiftUI

struct EventInput: View {
    @Query(sort: [SortDescriptor(\Event.key)]) private var events: [Event]
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""
    @Binding var selection: Set<Event>

    private var selectionArray: [Event] { Array(selection) }
    private var filteredEvents: [Event] {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return events }

        return events.filter { $0.name.localizedCaseInsensitiveContains(term) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Events")
                .font(.caption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8, lineSpacing: 4) {
                ForEach(selectionArray, id: \.self) {
                    event in
                    SidebarItemChip(
                        item: .event(event),
                        onRemove: { selection.remove(event) }
                    )
                }

                TextField("", text: $searchText)
                    .padding(.leading, selection.isEmpty ? 6 : 0)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    #if os(macOS) || os(iPadOS)
                        .textInputSuggestions {
                            if searchText.count > 1 {
                                ForEach(filteredEvents) { event in
                                    Label(event.name, systemImage: Event.icon)
                                    .textInputCompletion(event.name)
                                }
                            }
                        }
                    #endif
                    .onSubmit {
                        if let first = filteredEvents.first {
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
