import SwiftUI

extension View {
    @ViewBuilder
    func arrowKeyNavigation(
        onUp: @escaping () -> Void,
        onDown: @escaping () -> Void,
        onReturn: @escaping () -> Void
    ) -> some View {
        #if os(macOS)
            self.onKeyPress { key in
                switch key.key {
                case .upArrow:
                    onUp()
                    return .handled
                case .downArrow:
                    onDown()
                    return .handled
                case .return:
                    onReturn()
                    return .handled
                default:
                    return .ignored
                }
            }
        #else
            self.onMoveCommand { direction in
                switch direction {
                case .up:
                    onUp()
                case .down:
                    onDown()
                default:
                    break
                }
            }
        #endif
    }
}
