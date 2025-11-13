import SwiftData
import SwiftUI

struct TagEditorSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var parent: Tag?

    let tag: Tag?

    var title: String { tag == nil ? "New Tag" : "Edit Tag" }
    var trim: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    var canSave: Bool { !trim.isEmpty }

    init(_ tag: Tag? = nil) {
        self.tag = tag
        self._name = State(initialValue: tag?.name ?? "")
        self._parent = State(initialValue: tag?.parent)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                NameInput(name: $name).onSubmit { Task { try? await doWork() } }
                ParentPicker(parent: $parent, tag: tag)
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
        let tagStore = TagStore(modelContainer: context.container)

        if let tag {
            try await tagStore.update(tag.id, trim, parent?.id)
        } else {
            try await tagStore.create(trim, parent?.id)
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
                "e.g. Will Delete, For March Photobook",
                text: $name
            )
            .textFieldStyle(.roundedBorder)
            .focused($nameFocused)
            .task { nameFocused = true }
            .submitLabel(.done)
        }
    }
}

private struct ParentPicker: View {
    @Query(sort: \Tag.key) private var tags: [Tag]
    @Binding var parent: Tag?

    let tag: Tag?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Parent").font(.caption).foregroundStyle(.secondary)
            Picker("", selection: $parent) {
                Text("None").tag(Optional<Tag>.none)
                ForEach(tags) { t in
                    if tag.map({ !t.descendant(of: $0) && t !== $0 }) ?? true {
                        Text(t.name).tag(t)
                    }
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }
}
