import Foundation
import SwiftData

extension PhotoStore {
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
    
    private func getYear(_ id: UUID?) -> DateTakenYear? {
        guard let id else { return nil }

        let predicate = #Predicate<DateTakenYear> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenYear>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getMonth(_ id: UUID?) -> DateTakenMonth? {
        guard let id else { return nil }

        let predicate = #Predicate<DateTakenMonth> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenMonth>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getDay(_ id: UUID?) -> DateTakenDay? {
        guard let id else { return nil }

        let predicate = #Predicate<DateTakenDay> { $0.id == id }
        let descriptor = FetchDescriptor<DateTakenDay>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getCountry(_ id: UUID?) -> PlaceCountry? {
        guard let id else { return nil }

        let predicate = #Predicate<PlaceCountry> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceCountry>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getLocality(_ id: UUID?) -> PlaceLocality? {
        guard let id else { return nil }

        let predicate = #Predicate<PlaceLocality> { $0.id == id }
        let descriptor = FetchDescriptor<PlaceLocality>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results?.first
    }
    private func getTags(_ ids: [UUID]) -> [Tag] {
        let predicate = #Predicate<Tag> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results ?? []
    }
    private func getAlbums(_ ids: [UUID]) -> [Album] {
        let predicate = #Predicate<Album> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Album>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results ?? []

    }
    private func getPeople(_ ids: [UUID]) -> [Person] {
        let predicate = #Predicate<Person> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Person>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results ?? []

    }
    private func getEvents(_ ids: [UUID]) -> [Event] {
        let predicate = #Predicate<Event> { tag in ids.contains(tag.id) }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)
        let results = try? modelContext.fetch(descriptor)

        return results ?? []

    }
}
