import SwiftUI

struct PhotoCardTokens: Hashable {
    var size: CGFloat?
    var cornerRadius: CGFloat
}

enum PhotoCardVariant: Hashable {
    case pin
    case grid
    case detail

    var tokens: PhotoCardTokens {
        switch self {
        case .pin:
            return .init(size: 36, cornerRadius: 12)
        case .grid:
            return .init(size: nil, cornerRadius: 12)
        case .detail:
            return .init(size: nil, cornerRadius: 0)
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
                .fill(.thinMaterial)
            }
            .overlay {
                GeometryReader { proxy in
                    ThumbnailImageView(photo: photo)
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                        .clipped(antialiased: true)
                        .cornerRadius(variant.tokens.cornerRadius)
                }
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                ZStack {
                    Color.gray.opacity(0.1)
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        if let data = try? await store.get(
            for: photo.thumbnailFileName,
            bookmark: photo.bookmark,
            path: photo.path
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
    }
}
