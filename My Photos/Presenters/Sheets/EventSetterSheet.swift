import SwiftUI

struct EventSetterSheet: View {
    @Environment(PresentationState.self) private var state
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedEvents: Set<Event>

    @State private var task: Task<Void, Never>? = nil
    @State private var total: Int = 0
    @State private var completed: Int = 0
    @State private var isSaving = false
    
    private var formattedExistingEvents: String {
        let allEvents = Set(state.photoSelection.flatMap(\.events).sorted())
        let names = allEvents.map(\.name)

        return names.joined(separator: " • ")
    }

    init(event: Event? = nil) {
        if let event {
            _selectedEvents = State(initialValue: [event])
        } else {
            _selectedEvents = State(initialValue: [])
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                EventInput(selection: $selectedEvents)

                if formattedExistingEvents.isEmpty {
                    Text("The selected photos will be added to these events.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text(
                        "The selected photos will be added to these events. Some selected photos are also part of other events: \(formattedExistingEvents)"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .allowsHitTesting(!isSaving)
            .padding(20)
            .frame(minWidth: 400, minHeight: 200)
            .navigationTitle("Add Photos to Events")
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
        let eventIDs = selectedEvents.map(\.id)

        isSaving = true
        total = state.photoSelection.count
        completed = 0

        for id in photoIDs {
            if Task.isCancelled {
                isSaving = false
                dismiss()
            }

            try await photoStore.addEvents(id, eventIDs)
            completed += 1
        }

        try await photoStore.save()

        PhotoIntents.toggleSelectionMode()
        isSaving = false
        dismiss()
    }
}
