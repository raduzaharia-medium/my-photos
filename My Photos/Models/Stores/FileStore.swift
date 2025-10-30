import MapKit

struct FileStore {
    #if os(macOS)
        func parseImageFiles(in url: URL) throws -> [ParsedPhoto] {
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess { url.stopAccessingSecurityScopedResource() }
            }

            let imageFiles = try getImageFiles(in: url)
            var result: [ParsedPhoto] = []

            for imageFile in imageFiles {
                let props = Metadata.props(in: imageFile)
                let meta = Metadata.metadata(in: imageFile)
                let imageProps = ImageProps(props, meta)
                let acdsee = ACDSeeCategories(meta)

                //            if let location {
                //                if let request = MKReverseGeocodingRequest(
                //                    location: CLLocation(
                //                        latitude: location.latitude,
                //                        longitude: location.longitude
                //                    )
                //                ) {
                //                    let items = try await request.mapItems
                //                    if let item = items.first {
                //                        let placemark = item.addressRepresentations?.description
                //                        print("Resolved place: \(placemark)")
                //                    } else {
                //                        print("No reverse geocoding results.")
                //                    }
                //                    print(request.description)
                //                }
                //            }

                let photo = ParsedPhoto(
                    title: imageProps.title ?? imageFile.lastPathComponent,
                    description: imageProps.description,
                    dateTaken: imageProps.dateTaken,
                    location: imageProps.location,
                    country: imageProps.country ?? acdsee.country,
                    locality: imageProps.city ?? acdsee.locality,
                    tags: acdsee.categories,
                    albums: acdsee.albums
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
                    .isRegularFileKey, .contentTypeKey,
                ]
            )
        else { return [] }

        let result = enumerator.compactMap { $0 as? URL }
            .filter { url in
                guard
                    let values = try? url.resourceValues(forKeys: [
                        .isRegularFileKey, .contentTypeKey,
                    ])
                else {
                    return false
                }

                return values.isRegularFile == true
                    && values.contentType?.conforms(to: .image) == true
            }

        return result
    }
}
