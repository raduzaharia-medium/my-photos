import Foundation

final class PhotoImportService {
    let photoStore: PhotoStore
    let yearStore: YearStore
    let monthStore: MonthStore
    let dayStore: DayStore
    let tagStore: TagStore
    let countryStore: CountryStore
    let localityStore: LocalityStore
    let albumStore: AlbumStore
    let personStore: PersonStore

    init(
        photoStore: PhotoStore,
        yearStore: YearStore,
        monthStore: MonthStore,
        dayStore: DayStore,
        tagStore: TagStore,
        countryStore: CountryStore,
        localityStore: LocalityStore,
        albumStore: AlbumStore,
        personStore: PersonStore
    ) {
        self.photoStore = photoStore
        self.yearStore = yearStore
        self.monthStore = monthStore
        self.dayStore = dayStore
        self.tagStore = tagStore
        self.countryStore = countryStore
        self.localityStore = localityStore
        self.albumStore = albumStore
        self.personStore = personStore
    }

    func `import`(_ parsed: ParsedPhoto) -> Photo? {
        let existing = try? photoStore.get(by: parsed.fullPath)
        let notChanged = existing?.lastModifiedDate == parsed.lastModifiedDate
        guard notChanged == false else { return nil }

        var year: DateTakenYear? = nil
        var month: DateTakenMonth? = nil
        var day: DateTakenDay? = nil

        if let dateTaken = parsed.dateTaken {
            year = try? yearStore.ensure(
                Calendar.current.component(.year, from: dateTaken)
            )
            month = try? monthStore.ensure(
                year,
                Calendar.current.component(.month, from: dateTaken)
            )
            day = try? dayStore.ensure(
                month,
                Calendar.current.component(.day, from: dateTaken)
            )
        }

        let tags = tagStore.ensure(parsed.tags)
        let flatTags = tags.flatMap { $0.flatten() }
        let country = try? countryStore.ensure(parsed.country)
        let locality = try? localityStore.ensure(country, parsed.locality)
        let albums = albumStore.ensure(parsed.albums)
        let names = parsed.regions?.regionList.map(\.name) ?? []
        let people = personStore.ensure(names)

        let photo = Photo(
            fileName: parsed.fileName,
            path: parsed.path,
            fullPath: parsed.fullPath,
            creationDate: parsed.creationDate,
            lastModifiedDate: parsed.lastModifiedDate,
            bookmark: parsed.bookmark,
            title: parsed.title,
            description: parsed.description,
            dateTaken: parsed.dateTaken,
            dateTakenYear: year,
            dateTakenMonth: month,
            dateTakenDay: day,
            location: parsed.location,
            country: country,
            locality: locality,
            albums: albums,
            people: people,
            tags: flatTags,
        )

        try? photoStore.insert(photo)
        return photo
    }
}
