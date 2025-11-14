import SwiftUI

struct DateSetterSheet: View {
    @Environment(PresentationState.self) private var state
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate: Date
    
    @State private var task: Task<Void, Never>? = nil
    @State private var total: Int = 0
    @State private var completed: Int = 0
    @State private var isSaving = false
    @State private var formattedPhotoDates: String = ""

    init(year: Int? = nil, month: Int? = nil, day: Int? = nil)
    {
        let calendar = Calendar.current
        let year = year ?? calendar.component(.year, from: .now)
        let month = month ?? calendar.component(.month, from: .now)
        let day = day ?? calendar.component(.day, from: .now)
        let components = DateComponents(year: year, month: month, day: day)
        let date = calendar.date(from: components)

        self.selectedDate = calendar.startOfDay(for: date ?? .now)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                DateInput(date: $selectedDate)
                Text("Existing dates in selection: \(formattedPhotoDates)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .allowsHitTesting(!isSaving)
            .padding(20)
            .frame(minWidth: 400, minHeight: 200)
            .navigationTitle("Change Date Taken")
            .task {
                try? await loadFormattedPhotoDates()
            }
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

        isSaving = true
        total = photoIDs.count
        completed = 0

        for id in photoIDs {
            if Task.isCancelled {
                isSaving = false
                dismiss()
            }

            try await photoStore.setDateTaken(id, selectedDate)
            completed += 1
        }

        try await photoStore.save()

        PhotoIntents.toggleSelectionMode()
        isSaving = false
        dismiss()
    }

    @MainActor
    private func loadFormattedPhotoDates() async throws {
        let formatter = DateFormatter()

        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let dates = state.photoSelection.compactMap(\.dateTaken)
        let formatted = Set(dates).sorted().map { formatter.string(from: $0) }

        self.formattedPhotoDates = formatted.joined(separator: " • ")
    }
}
