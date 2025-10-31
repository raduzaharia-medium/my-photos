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
    func url(for photo: Photo) -> URL {
        directory.appendingPathComponent(photo.thumbnailFileName)
    }

    func get(for thumbnailFileName: String, photoPath: URL) async throws
        -> Data?
    {
        let targetURL = url(for: thumbnailFileName)
        if FileManager.default.fileExists(atPath: targetURL.path) {
            return try Data(contentsOf: targetURL)
        }

        // Generate and persist the thumbnail
        let data = try await generate(from: photoPath)
        try data.write(to: targetURL, options: [.atomic])
        return data
    }
    func get(for photo: Photo) async throws -> Data? {
        let needsAccess = photo.path.startAccessingSecurityScopedResource()
        defer {
            if needsAccess { photo.path.stopAccessingSecurityScopedResource() }
        }

        let targetURL = url(for: photo)
        if FileManager.default.fileExists(atPath: targetURL.path) {
            return try Data(contentsOf: targetURL)
        }

        // Generate and persist the thumbnail
        let data = try await generate(from: photo.path)
        try data.write(to: targetURL, options: [.atomic])
        return data
    }

    private func generate(from originalURL: URL) async throws
        -> Data
    {
        let needsAccess = originalURL.startAccessingSecurityScopedResource()
        defer {
            if needsAccess { originalURL.stopAccessingSecurityScopedResource() }
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 320,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]

        let path = originalURL.path
        let isFileURL = originalURL.isFileURL
        let exists = FileManager.default.fileExists(atPath: path)
        print("Thumb input URL:", originalURL)
        print("isFileURL:", isFileURL, "exists:", exists)

        guard let src = CGImageSourceCreateWithURL(originalURL as CFURL, nil)
        else {
            throw NSError(
                domain: "ThumbnailStore",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to create thumbnail file"
                ]
            )
        }

        let opt = options as CFDictionary
        let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, opt)
        guard let cgImage else {
            throw NSError(
                domain: "ThumbnailStore",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to create thumbnail image"
                ]
            )
        }

        let rep = NSBitmapImageRep(cgImage: cgImage)
        guard
            let data = rep.representation(
                using: .jpeg,
                properties: [.compressionFactor: 0.8]
            )
        else {
            throw NSError(
                domain: "ThumbnailStore",
                code: 3,
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to encode JPEG (macOS)"
                ]
            )
        }
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
