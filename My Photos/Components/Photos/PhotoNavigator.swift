import SwiftUI

struct PhotoNavigator: View {
    @State private var index: Int
    let photos: [Photo]

    init(photos: [Photo], index: Int) {
        self.photos = photos
        _index = State(initialValue: index)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if photos.indices.contains(index) {
                    PhotoCard(photos[index], variant: .detail)
                        .padding(16)
                        .animation(.default, value: index)
                } else {
                    Text("No photo")
                        .padding(32)
                }

                VStack {
                    Spacer()
                    HStack(spacing: 24) {
                        Button(action: { previous() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 36, height: 36)
                        }
                        .disabled(!canGoPrevious)

                        Button(action: { next() }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 36, height: 36)
                        }
                        .disabled(!canGoNext)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .shadow(radius: 8, y: 2)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
        }
        .focusable()
        .onKeyPress { key in
            switch key.key {
            case .leftArrow:
                previous()
                return .handled
            case .rightArrow:
                next()
                return .handled
            default: return .ignored
            }
        }
    }

    private var canGoPrevious: Bool { index > 0 }
    private var canGoNext: Bool { index + 1 < photos.count }

    private func previous() { if canGoPrevious { index -= 1 } }
    private func next() { if canGoNext { index += 1 } }
}
