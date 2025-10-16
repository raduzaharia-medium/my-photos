import SwiftUI

struct PersonEditorSheet: View {
    @FocusState private var nameFocused: Bool
    @State private var name: String

    let person: Person?

    var title: String { person == nil ? "New Person" : "Edit Person" }
    var trim: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { !trim.isEmpty }

    var onSave: (Person?, String) -> Void
    var onCancel: () -> Void

    init(
        _ person: Person? = nil,
        onSave: @escaping (Person?, String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.person = person
        self.onSave = onSave
        self.onCancel = onCancel

        _name = State(initialValue: person?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Name").font(.caption).foregroundStyle(.secondary)
                TextField("e.g. Michael, Sophie Smith", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { onSave(person, trim) }
            }.padding(20)
                .task { nameFocused = true }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { onCancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) {
                            onSave(person, trim)
                        }.keyboardShortcut(.defaultAction)
                            .disabled(!canSave)
                    }
                }
                .interactiveDismissDisabled(!canSave)
        }
    }
}
