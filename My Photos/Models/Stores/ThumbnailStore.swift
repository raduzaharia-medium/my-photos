import Foundation
import SwiftUI

actor ThumbnailStore: Sendable {
    private var caches: URL? {
        try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }
    private var thumbnails: URL? {
        caches?.appendingPathComponent("Thumbnails", isDirectory: true)
    }

    func url(for thumbnailFileName: String) -> URL? {
        thumbnails?.appendingPathComponent(thumbnailFileName)
    }

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
        guard let targetURL = url(for: thumbnail) else { return nil }
        let data = try await generate(from: sourceURL)

        try data.write(to: targetURL, options: [.atomic])
        return data
    }

    private func getExisting(from thumbnailFileName: String) -> Data? {
        guard let targetURL = url(for: thumbnailFileName) else { return nil }
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
