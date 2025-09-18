import SwiftUI

struct TagEditorSheet: View {
    @FocusState private var nameFocused: Bool
    @State private var name: String
    @State private var kind: TagKind

    let tag: Tag?

    var title: String { tag == nil ? "New Tag" : "Edit Tag" }
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var canSave: Bool { !trimmedName.isEmpty }

    var onSave: (Tag?, String, TagKind) -> Void
    var onCancel: () -> Void

    init(
        _ tag: Tag? = nil,
        onSave: @escaping (Tag?, String, TagKind) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.tag = tag
        self.onSave = onSave
        self.onCancel = onCancel

        _name = State(initialValue: tag?.name ?? "")
        _kind = State(initialValue: tag?.kind ?? .custom)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name").font(.caption).foregroundStyle(.secondary)
                    TextField("e.g. Vacation, Alice, 2025-08", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .focused($nameFocused)
                        .submitLabel(.done)
                        .onSubmit(save)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Type").font(.caption).foregroundStyle(.secondary)
                    Picker("Type", selection: $kind) {
                        ForEach(TagKind.allCases) { k in
                            Text(k.title).tag(k)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
            }.padding(20)
                .task { nameFocused = true }
                .frame(minWidth: 360)
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { onCancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", action: save)
                            .keyboardShortcut(.defaultAction)
                            .disabled(!canSave)
                    }
                }
                .interactiveDismissDisabled(!canSave)
        }
    }

    private func save() {
        guard canSave else { return }
        onSave(tag, trimmedName, kind)
    }
}
