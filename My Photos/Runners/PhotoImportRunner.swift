import Foundation
import SwiftData

@ModelActor
actor PhotoImportRunner {
    private lazy var photos = { PhotoStore(modelContainer: modelContainer) }()
    private lazy var years = { YearStore(modelContainer: modelContainer) }()
    private lazy var months = { MonthStore(modelContainer: modelContainer) }()
    private lazy var days = { DayStore(modelContainer: modelContainer) }()
    private lazy var tags = { TagStore(modelContainer: modelContainer) }()
    private lazy var ctrs = { CountryStore(modelContainer: modelContainer) }()
    private lazy var locs = { LocalityStore(modelContainer: modelContainer) }()
    private lazy var albums = { AlbumStore(modelContainer: modelContainer) }()
    private lazy var people = { PersonStore(modelContainer: modelContainer) }()

    func `import`(_ parsed: ParsedPhoto) async throws {
//        let existing = try? await photos.get(by: parsed.fullPath)
//        let notChanged = existing?.lastModifiedDate == parsed.lastModifiedDate
//        guard notChanged == false else { return false }

        var year: UUID? = nil
        var month: UUID? = nil
        var day: UUID? = nil

        if let dateTaken = parsed.dateTaken {
            let cYear = Calendar.current.component(.year, from: dateTaken)
            let cMonth = Calendar.current.component(.month, from: dateTaken)
            let cDay = Calendar.current.component(.day, from: dateTaken)

            year = try await years.ensure(cYear)
            month = try await months.ensure(year, cMonth)
            day = try await days.ensure(month, cDay)
        }

        let tags = await tags.ensure(parsed.tags)
        let country = try await ctrs.ensure(parsed.country)
        let locality = try await locs.ensure(country, parsed.locality)
        let albums = await albums.ensure(parsed.albums)
        let names = parsed.regions?.regionList.map(\.name) ?? []
        let people = await people.ensure(names)

        let snapshot = PhotoSnapshot(
            id: nil, 
            key: Photo.key(parsed.fileName),
            title: parsed.title,
            caption: nil, 
            dateTaken: parsed.dateTaken,
            location: parsed.location,
            fileName: parsed.fileName,
            path: parsed.path,
            fullPath: parsed.fullPath,
            creationDate: parsed.creationDate,
            lastModifiedDate: parsed.lastModifiedDate,
            bookmark: parsed.bookmark,
            thumbnailFileName: nil, 
            tags: tags,
            dateTakenYear: year,
            dateTakenMonth: month,
            dateTakenDay: day,
            country: country,
            locality: locality,
            albums: albums,
            people: people,
            events: []
        )

        // try? await photos.insert(snapshot)
    }
}

