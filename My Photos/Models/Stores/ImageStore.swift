import Foundation
import SwiftUI

final class ImageStore: Sendable {
    func get(bookmark: Data?, path: String) async throws -> Data? {
        guard let bookmark = bookmark else { throw Error.missingBookmark }
        guard let folderURL = resolve(bookmark) else { throw Error.urlResolve }

        let folderAccess = folderURL.startAccessingSecurityScopedResource()
        defer {
            if folderAccess { folderURL.stopAccessingSecurityScopedResource() }
        }

        let sourceURL = folderURL.appendingPathComponent(path)
        let data = try Data(contentsOf: sourceURL)

        return data
    }
    func get(for photo: Photo) async throws -> Data? {
        return try await get(bookmark: photo.bookmark, path: photo.path)
    }

    private func resolve(_ bookmark: Data) -> URL? {
        var isStale = false

        return try? URL(
            resolvingBookmarkData: bookmark,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }
}

private struct ImageStoreKey: EnvironmentKey {
    static let defaultValue: ImageStore? = nil
}

extension EnvironmentValues {
    var imageStore: ImageStore? {
        get { self[ImageStoreKey.self] }
        set { self[ImageStoreKey.self] = newValue }
    }
}

private enum Error: LocalizedError {
    case missingBookmark
    case urlResolve

    var errorDescription: String? {
        switch self {
        case .missingBookmark: return "No bookmark stored for photo"
        case .urlResolve: return "Failed to resolve URL"
        }
    }
}
