import Foundation
import SwiftUI

struct Thumbnail {
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

    let thumbnailFileName: String
    let bookmark: Data?
    let photoPath: String

    var url: URL? { thumbnails?.appendingPathComponent(thumbnailFileName) }

    func get() async throws -> Data? {
        if let ex = getExisting() { return ex }

        guard let url else { return nil }
        guard let data = try await generate() else { return nil }

        try data.write(to: url, options: [.atomic])
        return data
    }

    private func getExisting() -> Data? {
        guard let url else { return nil }
        let fileExists = FileManager.default.fileExists(atPath: url.path)

        guard fileExists else { return nil }
        return try? Data(contentsOf: url)
    }
    private func generate() async throws -> Data? {
        guard let folderURL = resolveBookmark() else { return nil }

        let folderAccess = folderURL.startAccessingSecurityScopedResource()
        defer {
            if folderAccess { folderURL.stopAccessingSecurityScopedResource() }
        }

        let sourceURL = folderURL.appendingPathComponent(photoPath)
        let options =
            [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 320,
                kCGImageSourceCreateThumbnailWithTransform: true,
            ] as CFDictionary
        let src = CGImageSourceCreateWithURL(sourceURL as CFURL, nil)
        guard let src else { return nil }

        let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, options)
        guard let cgImage else { return nil }

        let rep = NSBitmapImageRep(cgImage: cgImage)
        let data = rep.representation(
            using: .jpeg,
            properties: [.compressionFactor: 0.6]
        )
        guard let data else { return nil }

        return data
    }

    private func resolveBookmark() -> URL? {
        guard let bookmark else { return nil }
        var isStale = false

        return try? URL(
            resolvingBookmarkData: bookmark,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }
}
