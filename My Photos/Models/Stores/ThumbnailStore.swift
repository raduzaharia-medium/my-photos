import Foundation
import SwiftUI

final class ThumbnailStore: Sendable {
    private let directory: URL

    init(baseDirectory: FileManager.SearchPathDirectory = .cachesDirectory)
        throws
    {
        let base = try FileManager.default.url(
            for: baseDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = base.appendingPathComponent("Thumbnails", isDirectory: true)

        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(
                at: dir,
                withIntermediateDirectories: true
            )
        }

        self.directory = dir
    }

    func url(for thumbnailFileName: String) -> URL {
        directory.appendingPathComponent(thumbnailFileName)
    }
    func url(for photo: Photo) -> URL { url(for: photo.thumbnailFileName) }

    func get(for thumbnail: String, bookmark: Data?, path: String) async throws
        -> Data?
    {
        if let ex = getExisting(from: thumbnail) { return ex }
        guard let bookmark = bookmark else { throw Error.missingBookmark }
        guard let folderURL = resolve(bookmark) else { throw Error.urlResolve }

        let folderAccess = folderURL.startAccessingSecurityScopedResource()
        defer {
            if folderAccess { folderURL.stopAccessingSecurityScopedResource() }
        }

        let sourceURL = folderURL.appendingPathComponent(path)
        let targetURL = url(for: thumbnail)
        let data = try await generate(from: sourceURL)

        try data.write(to: targetURL, options: [.atomic])
        return data
    }
    func get(for photo: Photo) async throws -> Data? {
        return try await get(
            for: photo.thumbnailFileName,
            bookmark: photo.bookmark,
            path: photo.path
        )
    }

    private func getExisting(from thumbnailFileName: String) -> Data? {
        let targetURL = url(for: thumbnailFileName)
        let fileExists = FileManager.default.fileExists(atPath: targetURL.path)

        guard fileExists else { return nil }
        return try? Data(contentsOf: targetURL)
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
    private func generate(from originalURL: URL) async throws -> Data {
        let options =
            [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 320,
                kCGImageSourceCreateThumbnailWithTransform: true,
            ] as CFDictionary

        let src = CGImageSourceCreateWithURL(originalURL as CFURL, nil)
        guard let src else { throw Error.imageSource }

        let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, options)
        guard let cgImage else { throw Error.thumbnail }

        let rep = NSBitmapImageRep(cgImage: cgImage)
        let data = rep.representation(
            using: .jpeg,
            properties: [.compressionFactor: 0.6]
        )
        guard let data else { throw Error.jpeg }

        return data
    }
}

private struct ThumbnailStoreKey: EnvironmentKey {
    static let defaultValue: ThumbnailStore? = nil
}

extension EnvironmentValues {
    var thumbnailStore: ThumbnailStore? {
        get { self[ThumbnailStoreKey.self] }
        set { self[ThumbnailStoreKey.self] = newValue }
    }
}

private enum Error: LocalizedError {
    case missingBookmark
    case urlResolve
    case imageSource
    case thumbnail
    case jpeg

    var errorDescription: String? {
        switch self {
        case .missingBookmark: return "No bookmark stored for photo"
        case .urlResolve: return "Failed to resolve URL"
        case .imageSource: return "Failed to create thumbnail source"
        case .thumbnail: return "Failed to create thumbnail image"
        case .jpeg: return "Failed to encode JPEG"
        }
    }
}
