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
    case selectable

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
                cornerRadius: 16,
                shadowRadius: 8,
                shadowOpacity: 0.2,
                padding: 10,
            )
        case .selectable:
            return .init(
                size: nil,
                cornerRadius: 12,
                shadowRadius: 5,
                shadowOpacity: 0.15,
                padding: 8,
            )
        }
    }
}

struct PhotoCard: View {
    @Binding var isSelected: Bool

    private let photo: Photo
    private let variant: PhotoCardVariant

    init(_ photo: Photo, variant: PhotoCardVariant) {
        self.photo = photo
        self.variant = variant
        self._isSelected = PhotoCard.constantBinding(false)
    }

    init(_ photo: Photo, variant: PhotoCardVariant, isSelected: Binding<Bool>) {
        self.photo = photo
        self.variant = variant
        self._isSelected = isSelected
    }

    private static func constantBinding(_ value: Bool) -> Binding<Bool> {
        Binding<Bool>(
            get: { value },
            set: { _ in }
        )
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

            if variant == .selectable {
                Image(
                    systemName: isSelected ? "checkmark.circle.fill" : "circle"
                )
                .imageScale(.large)
                .padding(6)
            }
        }
        .applyIf(variant.tokens.size != nil) { view in
            view.frame(width: variant.tokens.size, height: variant.tokens.size)
        }
        .applyIf(variant.tokens.size == nil) { view in
            view.aspectRatio(1, contentMode: .fit)
        }
        .contentShape(Rectangle())
        .applyIf(variant == .selectable) { view in
            view.onTapGesture {
                isSelected.toggle()
            }
        }
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
