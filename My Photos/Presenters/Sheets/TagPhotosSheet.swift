import Combine
import SwiftUI

struct TagPhotosSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var total: Int = 0
    @State private var completed: Int = 0
    @State private var task: Task<Void, Never>? = nil

    let photoIDs: [UUID]
    let tags: [SidebarItem]

    var photoStore: PhotoStore { PhotoStore(modelContainer: context.container) }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ProgressView(
                    value: Double(completed),
                    total: Double(max(total, 1))
                ).padding()
                Text("Tagged \(Int(completed)) of \(Int(total))")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }.padding(20)
                .navigationTitle("Tagging photos")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            task?.cancel()
                            dismiss()
                        }
                    }
                }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            total = photoIDs.count
            completed = 0
            task = Task {
                for id in photoIDs {
                    if Task.isCancelled { return }

                    let albumIDs: [UUID] = tags.compactMap {
                        if case .album(let album) = $0 { album.id } else { nil }
                    }
                    let personIDs: [UUID] = tags.compactMap {
                        if case .person(let person) = $0 { person.id } else { nil }
                    }
                    let eventIDs: [UUID] = tags.compactMap {
                        if case .event(let event) = $0 { event.id } else { nil }
                    }
                    let tagIDs: [UUID] = tags.compactMap {
                        if case .tag(let tag) = $0 { tag.id } else { nil }
                    }
                    
                    try? await photoStore.addAlbums(id, albumIDs)
                    try? await photoStore.addPeople(id, personIDs)
                    try? await photoStore.addEvents(id, eventIDs)
                    try? await photoStore.addTags(id, tagIDs)
                    
                    completed += 1
                }
            }

            try? await Task.sleep(nanoseconds: 1_500_000_000)
            dismiss()
        }
    }
}
