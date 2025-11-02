import MapKit

struct FileStore {
    #if os(macOS)
        func parseImageFiles(in url: URL) throws -> [ParsedPhoto] {
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess { url.stopAccessingSecurityScopedResource() }
            }

            let bookmark = try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            let imageFiles = try getImageFiles(in: url)
            var result: [ParsedPhoto] = []

            for imageFile in imageFiles {
                let props = Metadata.props(in: imageFile)
                let meta = Metadata.metadata(in: imageFile)
                let imageProps = ImageProps(props, meta)
                let acdseeCategories = ACDSeeCategories(meta)
                let acdseeRegions = ACDSeeRegions(meta)
                let resourceValues = try imageFile.resourceValues(forKeys: [
                    .creationDateKey, .contentModificationDateKey,
                ])

                let photo = ParsedPhoto(
                    fileName: imageFile.lastPathComponent,
                    path: imageFile.path.replacingOccurrences(
                        of: url.path + "/",
                        with: ""
                    ),
                    fullPath: imageFile.absoluteString,
                    creationDate: resourceValues.creationDate,
                    lastModifiedDate: resourceValues.contentModificationDate,
                    bookmark: bookmark,
                    title: imageProps.title ?? imageFile.lastPathComponent,
                    description: imageProps.description,
                    dateTaken: imageProps.dateTaken,
                    location: imageProps.location,
                    country: imageProps.country ?? acdseeCategories.country,
                    locality: imageProps.city ?? acdseeCategories.locality,
                    tags: acdseeCategories.categories,
                    albums: acdseeCategories.albums,
                    regions: acdseeRegions.regions
                )

                result.append(photo)
            }

            return result
        }
    #endif

    private func getImageFiles(in url: URL) throws -> [URL] {
        guard
            let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: [
                    .isRegularFileKey, .contentTypeKey, .isSymbolicLinkKey,
                    .isReadableKey,
                ],
                options: [.skipsPackageDescendants, .skipsHiddenFiles],
                errorHandler: nil
            )
        else { return [] }

        let result = enumerator.compactMap { $0 as? URL }
            .filter { url in
                let values = try? url.resourceValues(forKeys: [
                    .isRegularFileKey, .contentTypeKey, .isSymbolicLinkKey,
                    .isReadableKey,
                ])
                guard let values, values.isSymbolicLink != true,
                    values.isRegularFile == true,
                    values.isReadable == true,
                    values.contentType?.conforms(to: .image) == true
                else {
                    return false
                }

                return true
            }

        return result
    }
}
