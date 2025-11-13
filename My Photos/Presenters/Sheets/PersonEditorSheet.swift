import SwiftUI

struct PersonEditorSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String

    let person: Person?

    var title: String { person == nil ? "New Person" : "Edit Person" }
    var trim: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { !trim.isEmpty }

    init(_ person: Person? = nil) {
        self.person = person
        self._name = State(initialValue: person?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                NameInput(name: $name).onSubmit { Task { try? await doWork() } }
                Spacer(minLength: 0)
            }.padding(20)
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) {
                            Task { try? await doWork() }
                        }.keyboardShortcut(.defaultAction)
                            .disabled(!canSave)
                    }
                }
                .interactiveDismissDisabled(!canSave)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    @MainActor
    private func doWork() async throws {
        let personStore = PersonStore(modelContainer: context.container)

        if let person {
            try await personStore.update(person.id, name: trim)
        } else {
            try await personStore.create(trim)
        }

        dismiss()
    }
}

private struct NameInput: View {
    @FocusState private var nameFocused: Bool
    @Binding var name: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name").font(.caption).foregroundStyle(.secondary)
            TextField(
                "e.g. Michael, Sophie Smith",
                text: $name
            )
            .textFieldStyle(.roundedBorder)
            .focused($nameFocused)
            .task { nameFocused = true }
            .submitLabel(.done)
        }
    }
}
