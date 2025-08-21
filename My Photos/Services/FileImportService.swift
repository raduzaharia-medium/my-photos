import SwiftUI
import UniformTypeIdentifiers

@MainActor
protocol FileImporter: AnyObject {
    func show(_ actionHandler: ((Result<[URL], Error>) -> Void)?)
    func dismiss()
}

@MainActor
final class FileImportService: ObservableObject, FileImporter {
    @Published var isVisible: Bool = false
    @Published var allowedContentTypes: [UTType] = [.folder]
    @Published var multipleSelection: Bool = false

    private var actionHandler: ((Result<[URL], Error>) -> Void)?

    func show(_ actionHandler: ((Result<[URL], Error>) -> Void)?) {
        withAnimation {
            self.actionHandler = actionHandler
            self.isVisible = true
        }
    }
    func dismiss() {
        withAnimation {
            self.actionHandler = nil
            self.isVisible = false
        }
    }

    func action(_ result: Result<[URL], Error>) {
        actionHandler?(result)
    }
}
