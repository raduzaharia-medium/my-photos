import SwiftData
import SwiftUI

@ModelActor
actor PhotoStore {
    func exists(_ fullPath: String) async throws -> Bool {
        let existing = try? get(by: fullPath)
        return existing != nil
    }
    func lastModifiedDate(_ fullPath: String) async throws -> Date? {
        let existing = try? get(by: fullPath)
        return existing?.lastModifiedDate ?? nil
    }

    func `import`(_ parsed: ParsedPhoto) async throws {
        let modified = try? await lastModifiedDate(parsed.fullPath)
        let notChanged = modified == parsed.lastModifiedDate
        guard modified == nil || notChanged == false else { return }

        let snapshot = try ensure(parsed)
        try? await insert(snapshot)
    }

    func tagPhotos(_ ids: [UUID], _ tags: [SidebarItem]) throws {
        for id in ids {
            let photo = try get(id)

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
    func tagPhoto(_ id: UUID, _ tags: [SidebarItem]) throws {
        let photo = try get(id)

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

    func setDateTaken(_ id: UUID, _ date: Date) throws {
        let photo = try get(id)

        photo.dateTaken = date
    }
    func setCountry(_ id: UUID, _ countryId: UUID) throws {
        let photo = try get(id)
        let country = try getCountry(countryId)
        
        photo.country = country
    }
    func setLocality(_ id: UUID, _ localityId: UUID) throws {
        let photo = try get(id)
        let locality = try getLocality(localityId)
        
        photo.locality = locality
    }

    func save() throws {
        try modelContext.save()
    }

    func getDateTaken(_ id: UUID) throws -> Date? {
        let photo = try get(id)
        return photo.dateTaken
    }
    func getDateTaken(_ ids: [UUID]) throws -> [UUID: Date?] {
        let photos = try ids.compactMap { try get($0) }
        let result = photos.reduce(into: [UUID: Date?]()) {
            $0[$1.id] = $1.dateTaken
        }

        return result
    }

    func addAlbums(_ id: UUID, _ albumIDs: [UUID]) throws {
        let photo = try get(id)

        for albumId in albumIDs {
            guard let album = try getAlbum(albumId) else {
                throw DataStoreError.invalidPredicate
            }

            photo.addAlbum(album)
        }
    }
    func addPeople(_ id: UUID, _ personIDs: [UUID]) throws {
        let photo = try get(id)

        for personId in personIDs {
            guard let person = try getPerson(personId) else {
                throw DataStoreError.invalidPredicate
            }

            photo.addPerson(person)
        }
    }
    func addEvents(_ id: UUID, _ eventIDs: [UUID]) throws {
        let photo = try get(id)

        for eventId in eventIDs {
            guard let event = try getEvent(eventId) else {
                throw DataStoreError.invalidPredicate
            }

            photo.addEvent(event)
        }
    }
    func addTags(_ id: UUID, _ tagIDs: [UUID]) throws {
        let photo = try get(id)

        for tagId in tagIDs {
            guard let tag = try getTag(tagId) else {
                throw DataStoreError.invalidPredicate
            }

            photo.addTag(tag)
        }
    }

    private func get(by fullPath: String) throws -> Photo? {
        let predicate = #Predicate<Photo> { $0.fullPath == fullPath }
        let descriptor = FetchDescriptor<Photo>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
    private func get(_ id: UUID) throws -> Photo {
        let predicate = #Predicate<Photo> { $0.id == id }
        let descriptor = FetchDescriptor<Photo>(predicate: predicate)
        let result = (try modelContext.fetch(descriptor)).first

        guard let result else { throw URLError(.fileDoesNotExist) }
        return result
    }

    private func getAlbum(_ id: UUID?) throws -> Album? {
        guard let id else { return nil }

        let predicate = #Predicate<Album> { $0.id == id }
        let descriptor = FetchDescriptor<Album>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
    private func getPerson(_ id: UUID?) throws -> Person? {
        guard let id else { return nil }

        let predicate = #Predicate<Person> { $0.id == id }
        let descriptor = FetchDescriptor<Person>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
    private func getEvent(_ id: UUID?) throws -> Event? {
        guard let id else { return nil }

        let predicate = #Predicate<Event> { $0.id == id }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        return (try modelContext.fetch(descriptor)).first
    }
    private func getTag(_ id: UUID?) throws -> Tag? {
        guard let id else { return nil }

        let predicate = #Predicate<Tag> { $0.id == id }
        let descriptor = FetchDescriptor<Tag>(predicate: predicate)

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
}
