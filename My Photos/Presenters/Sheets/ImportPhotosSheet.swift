import Combine
import SwiftUI

struct ImportPhotosSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var total: Int = 0
    @State private var completed: Int = 0
    @State private var importTask: Task<Void, Never>? = nil

    let folder: URL

    var photoStore: PhotoStore { PhotoStore(modelContainer: context.container) }

    private var progress: Double { Double(completed) / Double(total) }

    init(_ folder: URL) {
        self.folder = folder
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ProgressView(value: progress)
                    .padding()
                Text("Imported \(Int(completed)) of \(Int(total))")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }.padding(20)
                .navigationTitle("Importing photos")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            importTask?.cancel()
                            dismiss()
                        }
                    }
                }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            let parsed = try? await photoStore.parse(folder)
            guard let parsed else { return }
            guard parsed.count > 0 else { return }

            completed = 0
            total = parsed.count

            importTask = Task {
                for photo in parsed {
                    if Task.isCancelled { return }

                    try? await photoStore.import(photo)
                    completed += 1
                }

                try? await Task.sleep(nanoseconds: 2_000_000_000)
                dismiss()
            }
        }
    }
}
