import SwiftData
import SwiftUI

struct TagEditorSheet: View {
    @Query(sort: \Tag.key) private var tags: [Tag]

    @FocusState private var nameFocused: Bool
    @State private var name: String
    @State private var parent: Tag?

    let tag: Tag?

    var title: String { tag == nil ? "New Tag" : "Edit Tag" }
    var trim: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { !trim.isEmpty }

    var onSave: (Tag?, String, Tag?) -> Void
    var onCancel: () -> Void

    init(
        _ tag: Tag? = nil,
        onSave: @escaping (Tag?, String, Tag?) -> Void,
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name").font(.caption).foregroundStyle(.secondary)
                    TextField(
                        "e.g. Will Delete, For March Photobook",
                        text: $name
                    )
                    .textFieldStyle(.roundedBorder)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { onSave(tag, trim, parent) }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Parent").font(.caption).foregroundStyle(.secondary)
                    Picker("", selection: $parent) {
                        Text("None").tag(Optional<Tag>.none)
                        ForEach(tags) { t in
                            Text(t.name).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
            }.padding(20)
                .task { nameFocused = true }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) { onCancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", role: .confirm) {
                            onSave(tag, trim, parent)
                        }.keyboardShortcut(.defaultAction)
                            .disabled(!canSave)
                    }
                }
                .interactiveDismissDisabled(!canSave)
        }
    }
}
