import SwiftData
import SwiftUI

struct PersonInput: View {
    @Query(sort: [SortDescriptor(\Person.key)]) private var people: [Person]
    @FocusState private var isTextFieldFocused: Bool
    @State private var searchText: String = ""
    @Binding var selection: Set<Person>

    private var selectionArray: [Person] { Array(selection) }
    private var filteredPeople: [Person] {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return people }

        return people.filter { $0.name.localizedCaseInsensitiveContains(term) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("People")
                .font(.caption)
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 8, lineSpacing: 4) {
                ForEach(selectionArray, id: \.self) {
                    person in
                    SidebarItemChip(
                        item: .person(person),
                        onRemove: { selection.remove(person) }
                    )
                }

                TextField("", text: $searchText)
                    .padding(.leading, selection.isEmpty ? 6 : 0)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    #if os(macOS) || os(iPadOS)
                        .textInputSuggestions {
                            if searchText.count > 1 {
                                ForEach(filteredPeople) { person in
                                    Label(person.name, systemImage: Person.icon)
                                    .textInputCompletion(person.name)
                                }
                            }
                        }
                    #endif
                    .onSubmit {
                        if let first = filteredPeople.first {
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
