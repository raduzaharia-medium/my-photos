import SwiftData
import SwiftUI

struct DetailView: View {
    @Environment(PresentationState.self) private var presentationState

    var body: some View {        
        Group {
            switch presentationState.presentationMode {
            case .grid: PhotosGrid()
            case .map: PhotosMap()
            }
        }
        .toolbar {
            DetailViewToolbar()
        }
        .navigationTitle(
            (presentationState.selectedTags.count > 1)
                ? "Multiple Collections"
                : (presentationState.selectedTags.first?.name ?? "All Photos")
        )
        .setupPresentationModeHandlers(presentationState: presentationState)
    }
}
