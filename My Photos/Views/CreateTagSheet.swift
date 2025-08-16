//
//  CreateTagSheet.swift
//  My Photos
//
//  Created by Radu Zaharia on 16.08.2025.
//

import SwiftUI

struct CreateTagSheet: View {
    @FocusState private var nameFocused: Bool

    @Binding var name: String
    @Binding var kind: TagKind

    var onCancel: () -> Void
    var onCreate: (String, TagKind) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Tag").font(.title3).bold()

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
                Button("Create") {
                    onCreate(
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
    }
}
