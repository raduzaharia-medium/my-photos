import SwiftUI

struct ProgressIndicator: View {
    @Binding var isSaving: Bool
    @Binding var completed: Int
    @Binding var total: Int

    var body: some View {
        if isSaving && completed < total {
            ProgressView(
                value: Double(completed),
                total: Double(max(total, 1))
            )
            .progressViewStyle(.circular)
            .controlSize(.small)
        } else if isSaving && completed == total {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.small)
        }
    }
}
