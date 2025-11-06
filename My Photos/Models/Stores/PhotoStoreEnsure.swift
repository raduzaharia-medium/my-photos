import Foundation
import SwiftData

extension PhotoStore {
    func ensure(_ parsed: ParsedPhoto) throws -> PhotoSnapshot {
        var year: UUID? = nil
        var month: UUID? = nil
        var day: UUID? = nil

        if let dateTaken = parsed.dateTaken {
            let cYear = Calendar.current.component(.year, from: dateTaken)
            let cMonth = Calendar.current.component(.month, from: dateTaken)
            let cDay = Calendar.current.component(.day, from: dateTaken)

            year = try ensureYear(cYear)
            month = try ensureMonth(year, cMonth)
            day = try ensureDay(month, cDay)
        }

        let tags = try ensureTags(parsed.tags)
        let country = try ensureCountry(parsed.country)
        let locality = try ensureLocality(country, parsed.locality)
        let albums = try ensureAlbums(parsed.albums)
        let names = parsed.regions?.regionList.map(\.name) ?? []
        let people = try ensurePeople(names)

        return PhotoSnapshot(
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
    }

    private func getYear(_ year: Int) -> DateTakenYear? {
        let key = DateTakenYear.key(year)
        let predicate = #Predicate<DateTakenYear> { $0.key == key }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getYear(_ id: UUID?) -> DateTakenYear? {
        guard let id else { return nil }

        let predicate = #Predicate<DateTakenYear> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getMonth(_ parent: DateTakenYear, _ month: Int)
        -> DateTakenMonth?
    {
        let key = DateTakenMonth.key(parent, month)
        let predicate = #Predicate<DateTakenMonth> { $0.key == key }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getMonth(_ id: UUID) -> DateTakenMonth? {
        let predicate = #Predicate<DateTakenMonth> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getDay(_ parent: DateTakenMonth, _ day: Int) -> DateTakenDay? {
        let key = DateTakenDay.key(parent, day)
        let predicate = #Predicate<DateTakenDay> { $0.key == key }
        let descriptor = FetchDescriptor<DateTakenDay>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getCountry(_ name: String) -> PlaceCountry? {
        let key = PlaceCountry.key(name)
        let predicate = #Predicate<PlaceCountry> { item in item.key == key }
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getCountry(_ id: UUID) -> PlaceCountry? {
        let predicate = #Predicate<PlaceCountry> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getLocality(_ parent: PlaceCountry, _ name: String)
        -> PlaceLocality?
    {
        let key = PlaceLocality.key(parent, name)
        let predicate = #Predicate<PlaceLocality> { $0.key == key }
        let descriptor = FetchDescriptor<PlaceLocality>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }

    private func getAlbum(_ name: String) -> Album? {
        let key = Album.key(name)
        let predicate = #Predicate<Album> { album in album.key == key }
        let descriptor = FetchDescriptor<Album>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getPerson(_ name: String) -> Person? {
        let key = Person.key(name)
        let predicate = #Predicate<Person> { $0.key == key }
        let descriptor = FetchDescriptor<Person>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getTag(_ name: String) -> Tag? {
        let predicate = #Predicate<Tag> { $0.name == name }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }

    private func findOrCreateYear(_ year: Int) throws -> DateTakenYear {
        if let existing = getYear(year) { return existing }
        let item = DateTakenYear(year)

        modelContext.insert(item)
        try modelContext.save()
        return item
    }
    private func findOrCreateMonth(_ parent: DateTakenYear, _ month: Int) throws
        -> DateTakenMonth
    {
        if let existing = getMonth(parent, month) { return existing }
        let item = DateTakenMonth(parent, month)

        modelContext.insert(item)
        try modelContext.save()
        return item
    }
    private func findOrCreateDay(_ parent: DateTakenMonth, _ day: Int) throws
        -> DateTakenDay
    {
        if let existing = getDay(parent, day) { return existing }
        let item = DateTakenDay(parent, day)

        modelContext.insert(item)
        try modelContext.save()
        return item
    }
    func findOrCreateCountry(_ name: String) throws -> PlaceCountry {
        if let existing = getCountry(name) { return existing }
        let item = PlaceCountry(name)

        modelContext.insert(item)
        try modelContext.save()
        return item
    }
    func findOrCreateLocality(_ parent: PlaceCountry, _ name: String) throws
        -> PlaceLocality
    {
        if let existing = getLocality(parent, name) { return existing }
        let item = PlaceLocality(parent, name)

        modelContext.insert(item)
        try modelContext.save()
        return item
    }
    private func findOrCreateAlbum(_ name: String) throws -> Album {
        if let existing = getAlbum(name) { return existing }
        let item = Album(name)

        modelContext.insert(item)
        try modelContext.save()
        return item
    }
    private func findOrCreatePerson(_ name: String) throws -> Person {
        if let existing = getPerson(name) { return existing }
        let item = Person(name)

        modelContext.insert(item)
        try modelContext.save()
        return item
    }

    private func ensureYear(_ year: Int?) throws -> UUID? {
        guard let year else { return nil }
        let ensured = try findOrCreateYear(year)

        return ensured.id
    }
    private func ensureMonth(_ parentId: UUID?, _ month: Int?) throws -> UUID? {
        guard let parentId else { return nil }
        guard let month else { return nil }
        guard let parent = getYear(parentId) else { return nil }
        let ensured = try findOrCreateMonth(parent, month)

        return ensured.id
    }
    private func ensureDay(_ parentId: UUID?, _ day: Int?) throws -> UUID? {
        guard let parentId else { return nil }
        guard let day else { return nil }
        guard let parent = getMonth(parentId) else { return nil }

        let ensured = try findOrCreateDay(parent, day)
        return ensured.id
    }
    private func ensureCountry(_ name: String?) throws -> UUID? {
        guard let name else { return nil }
        let ensured = try findOrCreateCountry(name)

        return ensured.id
    }
    private func ensureLocality(_ parentId: UUID?, _ name: String?) throws
        -> UUID?
    {
        guard let parentId else { return nil }
        guard let name else { return nil }
        guard let parent = getCountry(parentId) else { return nil }
        let ensured = try findOrCreateLocality(parent, name)

        return ensured.id
    }
    private func ensureAlbums(_ names: [String]) throws -> [UUID] {
        return try names.map { name in
            let album = try findOrCreateAlbum(name)
            return album.id
        }
    }
    private func ensurePeople(_ names: [String]) throws -> [UUID] {
        return try names.map { name in
            let album = try findOrCreatePerson(name)
            return album.id
        }
    }
    private func ensureTags(_ incoming: [ParsedTag]) throws -> [UUID] {
        let resolved = try incoming.map { t in
            let resolved = try ensureTag(t)
            let flattened = resolved.flatten()
            let ids = flattened.map(\.id)

            return ids
        }

        return resolved.flatMap(\.self)
    }
    private func ensureTag(_ incoming: ParsedTag, _ parent: Tag? = nil)
        throws -> Tag
    {
        if let existing = getTag(incoming.name) {
            for child in incoming.children {
                let ensuredChild = try ensureTag(child, existing)

                if !existing.children.contains(where: { $0 === ensuredChild }) {
                    existing.children.append(ensuredChild)
                }
            }

            return existing
        } else {
            let item = Tag(name: incoming.name, parent: parent)

            for child in incoming.children {
                let ensuredChild = try ensureTag(child, item)

                if !item.children.contains(where: { $0 === ensuredChild }) {
                    item.children.append(ensuredChild)
                }
            }

            modelContext.insert(item)
            try modelContext.save()
            return item
        }
    }
}
