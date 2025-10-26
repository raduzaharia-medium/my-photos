import SwiftUI

struct DragPreviewStack: View {
    @Environment(PresentationState.self) private var state

    let count: Int

    var body: some View {
        ZStack {
            ZStack {
                ForEach(
                    Array(Array(state.photoSelection.prefix(4)).enumerated()),
                    id: \.offset
                ) { pair in
                    let idx = pair.offset
                    let photo = pair.element
                    let angle = Angle(degrees: Double(idx) * 4 - 6)
                    let offset = CGFloat(idx) * 6

                    thumbnail(for: photo)
                        .rotationEffect(angle)
                        .offset(x: offset, y: -offset)
                        .shadow(radius: 3, y: 2)
                }
            }
            .frame(width: 140, height: 100)

            VStack {
                HStack {
                    Spacer()
                    CountBadge(count: count)
                }
                Spacer()
            }
        }
        .padding(8)
        .background(.clear)
    }

    @ViewBuilder
    private func thumbnail(for photo: Photo) -> some View {
        PhotoCard(photo, variant: .grid)
            .frame(width: 110, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
