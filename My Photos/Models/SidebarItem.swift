import SwiftUI

enum SidebarItem: Hashable {
    case tag(Tag)
    case dateYear(DateTakenYear)
    case dateMonth(DateTakenMonth)
    case dateDay(DateTakenDay)
    case placeCountry(PlaceCountry)
    case placeLocality(PlaceLocality)
    case album(Album)
    case person(Person)
    case event(Event)

    var name: String {
        switch self {
        case .tag(let tag): return tag.name
        case .dateYear(let year): return "\(year.value)"
        case .dateMonth(let month): return monthName(month.value)
        case .dateDay(let day): return "\(day.value)"
        case .placeCountry(let country): return country.name
        case .placeLocality(let locality): return locality.name
        case .album(let album): return album.name
        case .person(let person): return person.name
        case .event(let event): return event.name
        }
    }

    var icon: String {
        switch self {
        case .tag: return Tag.icon
        case .dateYear: return DateTakenYear.icon
        case .dateMonth: return DateTakenMonth.icon
        case .dateDay: return DateTakenDay.icon
        case .placeCountry: return PlaceCountry.icon
        case .placeLocality: return PlaceLocality.icon
        case .album: return Album.icon
        case .person: return Person.icon
        case .event: return Event.icon
        }
    }

    var photos: [Photo] {
        switch self {
        case .tag(let tag): return tag.photos
        case .dateYear(let date): return date.photos
        case .dateMonth(let date): return date.photos
        case .dateDay(let date): return date.photos
        case .placeCountry(let place): return place.photos
        case .placeLocality(let place): return place.photos
        case .album(let album): return album.photos
        case .person(let person): return person.photos
        case .event(let event): return event.photos
        }
    }

    var editable: Bool {
        switch self {
        case .tag: return true
        case .dateDay, .dateMonth, .dateYear: return false
        case .placeCountry, .placeLocality: return false
        case .album, .person, .event: return true
        }
    }
    
    var id: UUID {
        switch self {
        case .tag(let tag): return tag.id
        case .dateYear(let date): return date.id
        case .dateMonth(let date): return date.id
        case .dateDay(let date): return date.id
        case .placeCountry(let place): return place.id
        case .placeLocality(let place): return place.id
        case .album(let album): return album.id
        case .person(let person): return person.id
        case .event(let event): return event.id
        }
    }


    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()

        formatter.locale = Locale.current
        return formatter.monthSymbols[max(0, min(11, month - 1))]
    }
}
