import SwiftUI

extension View {
    @ViewBuilder
    func cursorIBeamIfAvailable() -> some View {
        #if os(macOS)
            self.onHover { hovering in
                if hovering {
                    NSCursor.iBeam.push()
                } else {
                    NSCursor.pop()
                }
            }
        #else
            self
        #endif
    }
}
