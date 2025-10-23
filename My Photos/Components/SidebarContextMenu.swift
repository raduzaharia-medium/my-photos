import SwiftUI

private enum SelectionMode: Equatable {
    case none
    case singleTag(Tag)
    case singleAlbum(Album)
    case singlePerson(Person)
    case singleEvent(Event)
    case multipleTags([Tag])
    case multipleAlbums([Album])
    case multiplePersons([Person])
    case multipleEvents([Event])
}

extension Set where Element == SidebarItem {
    fileprivate var selectionMode: SelectionMode {
        let nonTagAlbumPersonEventItems = self.filter { item in
            switch item {
            case .tag, .album, .person, .event:
                return false
            default:
                return true
            }
        }
        guard nonTagAlbumPersonEventItems.isEmpty else { return .none }

        if !selectedTags.isEmpty && selectedAlbums.isEmpty && selectedPeople.isEmpty && selectedEvents.isEmpty {
            switch selectedTags.count {
            case 0:
                return .none
            case 1:
                return .singleTag(selectedTags[0])
            default:
                return .multipleTags(selectedTags)
            }
        }

        if selectedTags.isEmpty && !selectedAlbums.isEmpty && selectedPeople.isEmpty && selectedEvents.isEmpty {
            switch selectedAlbums.count {
            case 0:
                return .none
            case 1:
                return .singleAlbum(selectedAlbums[0])
            default:
                return .multipleAlbums(selectedAlbums)
            }
        }

        if selectedTags.isEmpty && selectedAlbums.isEmpty && !selectedPeople.isEmpty && selectedEvents.isEmpty {
            switch selectedPeople.count {
            case 0:
                return .none
            case 1:
                return .singlePerson(selectedPeople[0])
            default:
                return .multiplePersons(selectedPeople)
            }
        }

        if selectedTags.isEmpty && selectedAlbums.isEmpty && selectedPeople.isEmpty && !selectedEvents.isEmpty {
            switch selectedEvents.count {
            case 0:
                return .none
            case 1:
                return .singleEvent(selectedEvents[0])
            default:
                return .multipleEvents(selectedEvents)
            }
        }

        return .none
    }
}

struct SidebarContextMenu: View {
    var selection: Set<SidebarItem>

    init(_ selection: Set<SidebarItem>) {
        self.selection = selection
    }

    var body: some View {
        menu(for: selection.selectionMode)
    }
}

@MainActor
@ViewBuilder
private func menu(for mode: SelectionMode) -> some View {
    switch mode {
    case .none:
        EmptyView()
    case .singleTag(let tag):
        tagMenu(tag)
    case .singleAlbum(let album):
        albumMenu(album)
    case .multipleTags(let tags):
        multipleTagsMenu(tags)
    case .multipleAlbums(let albums):
        multipleAlbumsMenu(albums)
    case .singlePerson(let person):
        personMenu(person)
    case .singleEvent(let event):
        eventMenu(event)
    case .multiplePersons(let persons):
        multiplePersonsMenu(persons)
    case .multipleEvents(let events):
        multipleEventsMenu(events)
    }
}

@MainActor
@ViewBuilder
private func tagMenu(_ tag: Tag) -> some View {
    Button {
        TagIntents.requestEdit(tag)
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    Button(role: .destructive) {
        TagIntents.requestDelete(tag)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func albumMenu(_ album: Album) -> some View {
    Button {
        AlbumIntents.requestEdit(album)
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    Button(role: .destructive) {
        AlbumIntents.requestDelete(album)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func personMenu(_ person: Person) -> some View {
    Button {
        PersonIntents.requestEdit(person)
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    Button(role: .destructive) {
        PersonIntents.requestDelete(person)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func eventMenu(_ event: Event) -> some View {
    Button {
        EventIntents.requestEdit(event)
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    Button(role: .destructive) {
        EventIntents.requestDelete(event)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func multipleTagsMenu(_ tags: [Tag]) -> some View {
    Button(role: .destructive) {
        TagIntents.requestDelete(tags)
    } label: {
        Label("Delete \(tags.count) Tags", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func multipleAlbumsMenu(_ albums: [Album]) -> some View {
    Button(role: .destructive) {
        AlbumIntents.requestDelete(albums)
    } label: {
        Label("Delete \(albums.count) Albums", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func multiplePersonsMenu(_ persons: [Person]) -> some View {
    Button(role: .destructive) {
        PersonIntents.requestDelete(persons)
    } label: {
        Label("Delete \(persons.count) People", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func multipleEventsMenu(_ events: [Event]) -> some View {
    Button(role: .destructive) {
        EventIntents.requestDelete(events)
    } label: {
        Label("Delete \(events.count) Events", systemImage: "trash")
    }
}
