import SwiftUI

struct TagEditorSheet: View {
    @FocusState private var nameFocused: Bool
    @State private var name: String = ""
    @State private var kind: TagKind = .custom

    let title: String
    let initialName: String
    let initialKind: TagKind

    var onCancel: () -> Void
    var onSave: (String, TagKind) -> Void

    init(
        title: String,
        initialName: String,
        initialKind: TagKind,
        onCancel: @escaping () -> Void,
        onSave: @escaping (String, TagKind) -> Void
    ) {
        self.title = title
        self.initialName = initialName
        self.initialKind = initialKind
        self.onCancel = onCancel
        self.onSave = onSave

        _name = State(initialValue: initialName)
        _kind = State(initialValue: initialKind)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name").font(.caption).foregroundStyle(.secondary)
                TextField("e.g. Vacation, Alice, 2025-08", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($nameFocused)
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

            HStack {
                Spacer()
                Button("Cancel", role: .cancel, action: onCancel)
                Button("Save") {
                    onSave(
                        name.trimmingCharacters(in: .whitespacesAndNewlines),
                        kind
                    )
                }
                .keyboardShortcut(.defaultAction)
                .disabled(
                    name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
        }.padding(20)
            .onAppear { DispatchQueue.main.async { nameFocused = true } }
            .frame(minWidth: 360)
            .navigationTitle(Text(title))
    }
}
