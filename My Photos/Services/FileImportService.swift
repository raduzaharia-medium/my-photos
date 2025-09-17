import SwiftUI
import UniformTypeIdentifiers

@MainActor
protocol FileImporter: AnyObject {
    var isVisible: Bool { get set }
    var allowedContentTypes: [UTType] { get set }
    var multipleSelection: Bool { get set }
    
    func pickSingleFolder(_ actionHandler: ((Result<[URL], Error>) -> Void)?)
    
    func action(_ result: Result<[URL], Error>)
    func dismiss()
}

@MainActor
final class FileImportService: ObservableObject, FileImporter {
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
