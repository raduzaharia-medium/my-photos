import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class FileImportService: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var allowedContentTypes: [UTType] = []
    @Published var multipleSelection: Bool = false

    private var actionHandler: ((Result<[URL], Error>) -> Void)?

    func pickSingleFolder(_ actionHandler: ((Result<[URL], Error>) -> Void)?) {
        withAnimation {
            self.actionHandler = actionHandler
            self.allowedContentTypes = [.folder]
            self.multipleSelection = false
            self.isVisible = true
        }
    }
    func dismiss() {
        withAnimation {
            self.actionHandler = nil
            self.allowedContentTypes = []
            self.multipleSelection = false
            self.isVisible = false
        }
    }

    func action(_ result: Result<[URL], Error>) {
        actionHandler?(result)
    }
}
