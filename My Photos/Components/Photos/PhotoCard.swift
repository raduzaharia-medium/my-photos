import SwiftUI

struct PhotoCardTokens: Hashable {
    var size: CGFloat?
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    var shadowOpacity: Double
    var padding: CGFloat
}

enum PhotoCardVariant: Hashable {
    case pin
    case grid
    case detail

    var tokens: PhotoCardTokens {
        switch self {
        case .pin:
            return .init(
                size: 36,
                cornerRadius: 12,
                shadowRadius: 2,
                shadowOpacity: 0.15,
                padding: 4,
            )
        case .grid:
            return .init(
                size: nil,
                cornerRadius: 12,
                shadowRadius: 5,
                shadowOpacity: 0.15,
                padding: 8,
            )
        case .detail:
            return .init(
                size: nil,
                cornerRadius: 0,
                shadowRadius: 0,
                shadowOpacity: 0,
                padding: 10,
            )
        }
    }
}

struct PhotoCard: View {
    #if os(iOS)
        @Environment(PresentationState.self) private var presentationState
    #endif

    #if os(macOS) || os(iPadOS)
        @Environment(\.controlActiveState) private var controlActiveState
    #endif

    private let photo: Photo
    private let variant: PhotoCardVariant
    private var isSelected: Bool

    init(_ photo: Photo, variant: PhotoCardVariant, isSelected: Bool = false) {
        self.photo = photo
        self.variant = variant
        self.isSelected = isSelected
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: variant.tokens.cornerRadius,
                    style: .continuous
                )
                .fill(.white)
                .shadow(
                    color: .black.opacity(variant.tokens.shadowOpacity),
                    radius: variant.tokens.shadowRadius,
                    x: 0,
                    y: 2
                )
            }
            .overlay {
                ThumbnailImageView(photo: photo)
                    .clipped()
                    .cornerRadius(variant.tokens.cornerRadius)
                    .padding(variant.tokens.padding)
            }

            #if os(iOS)
                if variant == .grid && presentationState.photoSelectionMode {
                    Image(
                        systemName: isSelected
                            ? "checkmark.circle.fill" : "circle"
                    )
                    .imageScale(.large)
                    .padding(6)
                }
            #endif
        }
        .applyIf(variant.tokens.size != nil) { view in
            view.frame(width: variant.tokens.size, height: variant.tokens.size)
        }
        .applyIf(variant.tokens.size == nil) { view in
            view.aspectRatio(1, contentMode: .fit)
        }
        .contentShape(Rectangle())
        #if os(macOS)
            .overlay(
                RoundedRectangle(
                    cornerRadius: variant.tokens.cornerRadius,
                    style: .continuous
                )
                .stroke(
                    isSelected
                        ? (controlActiveState == .inactive
                            ? Color.gray.opacity(0.8) : Color.accentColor)
                        : Color.clear,
                    lineWidth: isSelected ? 2 : 0
                )
            )
        #endif
    }
}

extension View {
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, transform: (Self) -> T)
        -> some View
    {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

private struct ThumbnailImageView: View {
    @Environment(\.thumbnailStore) private var thumbnailStore
    @State private var image: Image?
    @State private var isLoading = false

    let photo: Photo

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color.gray.opacity(0.1)
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
                .task(id: photo.id) {
                    await loadThumbnail()
                }
            }
        }
    }

    @MainActor
    private func loadThumbnail() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        guard let store = thumbnailStore else { return }
        do {
            if let data = try await thumbnailStore?.get(
                for: photo.thumbnailFileName,
                photoPath: photo.path
            ) {
                #if os(iOS) || os(tvOS) || os(visionOS)
                    if let uiImage = UIImage(data: data) {
                        image = Image(uiImage: uiImage)
                    }
                #elseif os(macOS)
                    if let nsImage = NSImage(data: data) {
                        image = Image(nsImage: nsImage)
                    }
                #endif
            }
        } catch {
            // Optionally log the error in DEBUG
            #if DEBUG
                print("[ThumbnailImageView] Failed to load thumbnail: \(error)")
            #endif
        }
    }
}
