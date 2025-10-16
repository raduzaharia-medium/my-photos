import SwiftUI

struct EventEditorSheet: View {
    @FocusState private var nameFocused: Bool
    @State private var name: String

    let event: Event?

    var title: String { event == nil ? "New Event" : "Edit Event" }
    var trim: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { !trim.isEmpty }

    var onSave: (Event?, String) -> Void
    var onCancel: () -> Void

    init(
        _ event: Event? = nil,
        onSave: @escaping (Event?, String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.event = event
        self.onSave = onSave
        self.onCancel = onCancel

        _name = State(initialValue: event?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Name").font(.caption).foregroundStyle(.secondary)
                TextField("e.g. My Birthday, Yearly Marathon", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { onSave(event, trim) }
            }.padding(20)
                .task { nameFocused = true }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { onCancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) {
                            onSave(event, trim)
                        }.keyboardShortcut(.defaultAction)
                            .disabled(!canSave)
                    }
                }
                .interactiveDismissDisabled(!canSave)
        }
    }
}
