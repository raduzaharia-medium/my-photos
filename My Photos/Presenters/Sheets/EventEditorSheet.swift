import SwiftUI

struct EventEditorSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String

    let event: Event?

    var title: String { event == nil ? "New Event" : "Edit Event" }
    var trim: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { !trim.isEmpty }

    init(_ event: Event? = nil) {
        self.event = event
        self._name = State(initialValue: event?.name ?? "")
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
        let eventStore = EventStore(modelContainer: context.container)

        if let event {
            try await eventStore.update(event.id, trim)
        } else {
            try await eventStore.create(trim)
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
                "e.g. My Birthday, Yearly Marathon",
                text: $name
            )
            .textFieldStyle(.roundedBorder)
            .focused($nameFocused)
            .task { nameFocused = true }
            .submitLabel(.done)
        }
    }
}
