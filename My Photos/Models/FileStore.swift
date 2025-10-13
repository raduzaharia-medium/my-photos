import MapKit

struct FileStore {
    func parseImageFiles(in url: URL) async throws -> [Photo] {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
        }

        let imageFiles = try getImageFiles(in: url)
        var result: [Photo] = []

        for imageFile in imageFiles {
            let props = Metadata.props(in: imageFile)
            let tags = Metadata.tags(in: imageFile)
            let imageProps = ImageProps(props)
            let acdsee = ACDSeeCategories(tags)

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

            let photo = Photo(
                title: imageProps.title ?? imageFile.lastPathComponent,
                description: imageProps.description,
                dateTaken: imageProps.dateTaken,
                location: imageProps.location,
                tags: acdsee.places
            )
            result.append(photo)
        }

        return result
    }

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
