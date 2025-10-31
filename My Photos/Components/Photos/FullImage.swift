import SwiftUI

struct FullImage: View {
    @Environment(\.imageStore) private var imageStore
    @State private var image: Image?
    @State private var isLoading = false
    @State private var error = false

    let photo: Photo

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else if error {
                ZStack {
                    Color.gray.opacity(0.1)
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("Unable to load")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Image failed to load")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    Color.gray.opacity(0.1)

                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.secondary)
                        .accessibilityLabel("Loading image")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .task(id: photo.id) { await load() }
            }
        }
    }

    @MainActor
    private func load() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        guard let store = imageStore else {
            error = true
            return
        }

        guard
            let data = try? await store.get(
                bookmark: photo.bookmark,
                path: photo.path
            )
        else {
            error = true
            return
        }

        #if os(iOS) || os(tvOS) || os(visionOS)
            if let uiImage = UIImage(data: data) {
                image = Image(uiImage: uiImage)
            } else {
                error = true
            }
        #elseif os(macOS)
            if let nsImage = NSImage(data: data) {
                image = Image(nsImage: nsImage)
            } else {
                error = true
            }
        #endif
    }
}
