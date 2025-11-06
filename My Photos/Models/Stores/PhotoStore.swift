import SwiftData
import SwiftUI

@ModelActor
actor PhotoStore {
    func get(by fullPath: String) throws -> Photo? {
        let descriptor = FetchDescriptor<Photo>(
            predicate: #Predicate { $0.fullPath == fullPath }
        )

        return (try? modelContext.fetch(descriptor))?.first
    }

    func exists(_ fullPath: String) async throws -> Bool {
        let existing = try? get(by: fullPath)
        return existing != nil
    }
    func lastModifiedDate(_ fullPath: String) async throws -> Date? {
        let existing = try? get(by: fullPath)
        return existing?.lastModifiedDate ?? nil
    }

    func insert(_ photo: Photo) throws {
        modelContext.insert(photo)
        try modelContext.save()
    }
    func insert(_ photos: [Photo]) throws {
        for photo in photos {
            modelContext.insert(photo)
        }

        try modelContext.save()
    }
    func insert(_ snapshot: PhotoSnapshot) async throws {
        let dateTakenYear = getYear(snapshot.dateTakenYear)
        let dateTakenMonth = getMonth(snapshot.dateTakenMonth)
        let dateTakenDay = getDay(snapshot.dateTakenDay)
        let country = getCountry(snapshot.country)
        let locality = getLocality(snapshot.locality)
        let albums = getAlbums(snapshot.albums)
        let people = getPeople(snapshot.people)
        let events = getEvents(snapshot.events)
        let tags = getTags(snapshot.tags)

        let photo = Photo(
            fileName: snapshot.fileName,
            path: snapshot.path,
            fullPath: snapshot.fullPath,
            creationDate: snapshot.creationDate,
            lastModifiedDate: snapshot.lastModifiedDate,
            bookmark: snapshot.bookmark,
            title: snapshot.title,
            dateTaken: snapshot.dateTaken,
            dateTakenYear: dateTakenYear,
            dateTakenMonth: dateTakenMonth,
            dateTakenDay: dateTakenDay,
            location: snapshot.location,
            country: country,
            locality: locality,
            albums: albums,
            people: people,
            events: events,
            tags: tags
        )

        modelContext.insert(photo)
        try modelContext.save()
    }

    func tagPhotos(_ photos: [Photo], _ tags: [SidebarItem]) throws {
        for photo in photos {
            for tag in tags {
                if !photo.tags.contains(where: { $0.id == tag.id }) {
                    if case .album(let album) = tag { photo.addAlbum(album) }
                    if case .person(let person) = tag {
                        photo.addPerson(person)
                    }
                    if case .event(let event) = tag { photo.addEvent(event) }
                    if case .tag(let tag) = tag { photo.addTag(tag) }
                }
            }
        }

        try modelContext.save()
    }

    private func photosForCountry(key: String) -> Set<Photo> {
        let descriptor = FetchDescriptor<PlaceCountry>(
            predicate: #Predicate { $0.key == key }
        )
        if let model = try? modelContext.fetch(descriptor).first {
            return Set(model.photos)
        }
        return []
    }

    private func photosForLocality(key: String) -> Set<Photo> {
        let descriptor = FetchDescriptor<PlaceLocality>(
            predicate: #Predicate { $0.key == key }
        )
        if let model = try? modelContext.fetch(descriptor).first {
            return Set(model.photos)
        }
        return []
    }
    
    private func getYear(_ id: UUID?) -> DateTakenYear? {
        guard let id else { return nil }
        
        let predicate = #Predicate<DateTakenYear> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    private func getMonth(_ id: UUID?) -> DateTakenMonth? {
        guard let id else { return nil }
        
        let predicate = #Predicate<DateTakenMonth> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    private func getDay(_ id: UUID?) -> DateTakenDay? {
        guard let id else { return nil }
        
        let predicate = #Predicate<DateTakenDay> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenDay>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    private func getCountry(_ id: UUID?) -> PlaceCountry? {
        guard let id else { return nil }
        
        let predicate = #Predicate<PlaceCountry> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    private func getLocality(_ id: UUID?) -> PlaceLocality? {
        guard let id else { return nil }
        
        let predicate = #Predicate<PlaceLocality> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceLocality>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        guard let results else { return nil }
        guard let fetched = results.first else { return nil }

        return fetched
    }
    private func getTags(_ ids: [UUID]) -> [Tag] {
        let predicate = #Predicate<Tag> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)

        return (try? modelContext.fetch(descriptor)) ?? []
    }
    private func getAlbums(_ ids: [UUID]) -> [Album] {
        let predicate = #Predicate<Album> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Album>(predicate: predicate)

        return (try? modelContext.fetch(descriptor)) ?? []
    }
    private func getPeople(_ ids: [UUID]) -> [Person] {
        let predicate = #Predicate<Person> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Person>(predicate: predicate)

        return (try? modelContext.fetch(descriptor)) ?? []
    }
    private func getEvents(_ ids: [UUID]) -> [Event] {
        let predicate = #Predicate<Event> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
