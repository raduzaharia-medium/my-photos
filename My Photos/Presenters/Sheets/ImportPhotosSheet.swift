import Combine
import SwiftUI

struct ImportPhotosSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completed: Int = 0
    @State private var importTask: Task<Void, Never>? = nil

    let parsed: [ParsedPhoto]
    let photoImporter: PhotoImportRunner

    private var total: Int { parsed.count }
    private var progress: Double { Double(completed) / Double(total) }

    init(_ parsed: [ParsedPhoto], _ photoImporter: PhotoImportRunner) {
        self.parsed = parsed
        self.photoImporter = photoImporter
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ProgressView(value: progress).padding()
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
            // Reset progress
            completed = 0
            guard total > 0 else { return }
            importTask = Task {
                for photo in parsed {
                    if Task.isCancelled { break }

                    await photoImporter.import(photo)                  
                    await MainActor.run { completed += 1 }
                }
                await MainActor.run {
                    if completed >= total {
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            importTask?.cancel()
        }
    }
}
