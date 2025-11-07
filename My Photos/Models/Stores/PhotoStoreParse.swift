import Foundation

extension PhotoStore {
    func getPhotos(in url: URL) throws -> [URL] {
        guard let enumerator = getEnumerator(url) else { return [] }

        let result = try enumerator.compactMap { $0 as? URL }
            .filter { url in
                let values = try url.resourceValues(forKeys: [
                    .isRegularFileKey, .contentTypeKey, .isSymbolicLinkKey,
                    .isReadableKey,
                ])

                return values.isSymbolicLink != true
                    && values.isRegularFile == true && values.isReadable == true
                    && values.contentType?.conforms(to: .image) == true
            }

        return result
    }

    #if os(macOS)
        func parse(_ folderUrl: URL, _ folderBookmark: Data, _ fileUrl: URL)
            throws -> ParsedPhoto
        {
            let props = Metadata.props(in: fileUrl)
            let meta = Metadata.metadata(in: fileUrl)
            let imageProps = ImageProps(props, meta)
            let acdseeCategories = ACDSeeCategories(meta)
            let acdseeRegions = ACDSeeRegions(meta)
            let resourceValues = try fileUrl.resourceValues(forKeys: [
                .creationDateKey, .contentModificationDateKey,
            ])

            return ParsedPhoto(
                fileName: fileUrl.lastPathComponent,
                path: fileUrl.path.replacingOccurrences(
                    of: folderUrl.path + "/",
                    with: ""
                ),
                fullPath: fileUrl.absoluteString,
                creationDate: resourceValues.creationDate,
                lastModifiedDate: resourceValues.contentModificationDate,
                bookmark: folderBookmark,
                title: imageProps.title ?? fileUrl.lastPathComponent,
                description: imageProps.description,
                dateTaken: imageProps.dateTaken,
                location: imageProps.location,
                country: imageProps.country ?? acdseeCategories.country,
                locality: imageProps.city ?? acdseeCategories.locality,
                tags: acdseeCategories.categories,
                albums: acdseeCategories.albums,
                regions: acdseeRegions.regions
            )
        }
    #endif

    private func getEnumerator(_ url: URL) -> FileManager
        .DirectoryEnumerator?
    {
        return FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [
                .isRegularFileKey, .contentTypeKey, .isSymbolicLinkKey,
                .isReadableKey,
            ],
            options: [.skipsPackageDescendants, .skipsHiddenFiles],
            errorHandler: nil
        )
    }
}
