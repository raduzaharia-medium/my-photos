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
    @Environment(PresentationState.self) private var presentationState

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
                Text(photo.title)
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
