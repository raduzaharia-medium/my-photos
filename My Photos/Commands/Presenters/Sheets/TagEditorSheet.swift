import SwiftUI

struct TagEditorSheet: View {
    @FocusState private var nameFocused: Bool
    @State private var name: String

    let tag: Tag?

    var title: String { tag == nil ? "New Tag" : "Edit Tag" }
    var trim: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { !trim.isEmpty }

    var onSave: (Tag?, String) -> Void
    var onCancel: () -> Void

    init(
        _ tag: Tag? = nil,
        onSave: @escaping (Tag?, String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.tag = tag
        self.onSave = onSave
        self.onCancel = onCancel

        _name = State(initialValue: tag?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Name").font(.caption).foregroundStyle(.secondary)
                TextField("e.g. Will Delete, For March Photobook", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { onSave(tag, trim) }
            }.padding(20)
                .task { nameFocused = true }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { onCancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) {
                            onSave(tag, trim)
                        }.keyboardShortcut(.defaultAction)
                            .disabled(!canSave)
                    }
                }
                .interactiveDismissDisabled(!canSave)
        }
    }
}
