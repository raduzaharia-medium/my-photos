import Foundation
import SwiftData

extension PhotoStore {
    func insert(_ snapshot: PhotoSnapshot) async throws {
        let dateTakenYear = try getYear(snapshot.dateTakenYear)
        let dateTakenMonth = try getMonth(snapshot.dateTakenMonth)
        let dateTakenDay = try getDay(snapshot.dateTakenDay)
        let country = try getCountry(snapshot.country)
        let locality = try getLocality(snapshot.locality)
        let albums = try getAlbums(snapshot.albums)
        let people = try getPeople(snapshot.people)
        let events = try getEvents(snapshot.events)
        let tags = try getTags(snapshot.tags)

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

    private func getYear(_ id: UUID?) throws -> DateTakenYear? {
        guard let id else { return nil }

        let predicate = #Predicate<DateTakenYear> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
    private func getMonth(_ id: UUID?) throws -> DateTakenMonth? {
        guard let id else { return nil }

        let predicate = #Predicate<DateTakenMonth> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
    private func getDay(_ id: UUID?) throws -> DateTakenDay? {
        guard let id else { return nil }

        let predicate = #Predicate<DateTakenDay> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenDay>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
    private func getCountry(_ id: UUID?) throws -> PlaceCountry? {
        guard let id else { return nil }

        let predicate = #Predicate<PlaceCountry> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
    private func getLocality(_ id: UUID?) throws -> PlaceLocality? {
        guard let id else { return nil }

        let predicate = #Predicate<PlaceLocality> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceLocality>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
    private func getTags(_ ids: [UUID]) throws -> [Tag] {
        let predicate = #Predicate<Tag> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)

        return try modelContext.fetch(descriptor)
    }
    private func getAlbums(_ ids: [UUID]) throws -> [Album] {
        let predicate = #Predicate<Album> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Album>(predicate: predicate)

        return try modelContext.fetch(descriptor)
    }
    private func getPeople(_ ids: [UUID]) throws -> [Person] {
        let predicate = #Predicate<Person> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Person>(predicate: predicate)

        return try modelContext.fetch(descriptor)
    }
    private func getEvents(_ ids: [UUID]) throws -> [Event] {
        let predicate = #Predicate<Event> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        return try modelContext.fetch(descriptor)
    }
}
