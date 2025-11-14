import SwiftUI

struct PersonSetterSheet: View {
    @Environment(PresentationState.self) private var state
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPeople: Set<Person>

    @State private var task: Task<Void, Never>? = nil
    @State private var total: Int = 0
    @State private var completed: Int = 0
    @State private var isSaving = false

    private var formattedExistingPeople: String {
        let allPeople = Set(state.photoSelection.flatMap(\.people).sorted())
        let names = allPeople.map(\.name)

        return names.joined(separator: " • ")
    }

    init(person: Person? = nil) {
        if let person {
            _selectedPeople = State(initialValue: [person])
        } else {
            _selectedPeople = State(initialValue: [])
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                PersonInput(selection: $selectedPeople)

                if formattedExistingPeople.isEmpty {
                    Text("The selected photos will mark these people.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text(
                        "The selected photos will mark these people. Some selected photos also have other people: \(formattedExistingPeople)"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .allowsHitTesting(!isSaving)
            .padding(20)
            .frame(minWidth: 400, minHeight: 200)
            .navigationTitle("Add People to Photos")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        task?.cancel()
                        isSaving = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        task = Task { try? await doWork() }
                    } label: {
                        Text("Save")
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .automatic) {
                    ProgressIndicator(
                        isSaving: $isSaving,
                        completed: $completed,
                        total: $total
                    )
                }
            }
        }
    }

    @MainActor
    private func doWork() async throws {
        let photoStore = PhotoStore(modelContainer: context.container)
        let photoIDs = state.photoSelection.map(\.id)
        let peopleIDs = selectedPeople.map(\.id)

        isSaving = true
        total = state.photoSelection.count
        completed = 0

        for id in photoIDs {
            if Task.isCancelled {
                isSaving = false
                dismiss()
            }

            try await photoStore.addPeople(id, peopleIDs)
            completed += 1
        }

        try await photoStore.save()

        PhotoIntents.toggleSelectionMode()
        isSaving = false
        dismiss()
    }
}
