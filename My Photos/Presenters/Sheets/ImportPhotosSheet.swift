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

    init(_ folder: URL) {
        self.folder = folder
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ProgressView(
                    value: Double(completed),
                    total: Double(max(total, 1))
                ).padding()
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
            let didAccess = folder.startAccessingSecurityScopedResource()
            defer {
                if didAccess { folder.stopAccessingSecurityScopedResource() }
            }

            let bookmark = try? folder.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            guard let bookmark else { return }

            let files = try? await photoStore.getPhotos(in: folder)
            guard let files else { return }

            total = files.count
            completed = 0
            importTask = Task {
                for file in files {
                    if Task.isCancelled { return }

                    let parsed = try? await photoStore.parse(
                        folder,
                        bookmark,
                        file
                    )
                    guard let parsed else { continue }

                    try? await photoStore.import(parsed)
                    completed += 1
                }
            }

            try? await Task.sleep(nanoseconds: 1_500_000_000)
            dismiss()
        }
    }
}
