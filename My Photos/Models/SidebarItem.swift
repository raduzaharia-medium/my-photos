import SwiftUI

enum SidebarItem: Hashable {
    case filter(Filter)
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
        case .filter(let filter): return filter.name
        case .tag(let tag): return tag.name
        case .dateYear(let date): return "\(date.year)"
        case .dateMonth(let date): return monthName(date.month)
        case .dateDay(let date): return "\(date.day)"
        case .placeCountry(let place): return place.country
        case .placeLocality(let place): return place.locality
        case .album(let album): return album.name
        case .person(let person): return person.name
        case .event(let event): return event.name
        }
    }

    var icon: String {
        switch self {
        case .filter(let filter): return filter.icon
        case .tag(let tag): return tag.icon
        case .dateYear(let year): return year.icon
        case .dateMonth(let month): return month.icon
        case .dateDay(let day): return day.icon
        case .placeCountry(let country): return country.icon
        case .placeLocality(let locality): return locality.icon
        case .album(let album): return album.icon
        case .person(let person): return person.icon
        case .event(let event): return event.icon
        }
    }

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()

        formatter.locale = Locale.current

        return formatter.monthSymbols[max(0, min(11, month - 1))]
    }
}

extension Set where Element == SidebarItem {
    var selectedTags: [Tag] {
        compactMap {
            if case .tag(let t) = $0 { t } else { nil }
        }
    }
    var selectedFilters: [Filter] {
        compactMap {
            if case .filter(let t) = $0 { t } else { nil }
        }
    }
    var selectedYears: [DateTakenYear] {
        compactMap {
            if case .dateYear(let t) = $0 { t } else { nil }
        }
    }
    var selectedMonths: [DateTakenMonth] {
        compactMap {
            if case .dateMonth(let t) = $0 { t } else { nil }
        }
    }
    var selectedDays: [DateTakenDay] {
        compactMap {
            if case .dateDay(let t) = $0 { t } else { nil }
        }
    }
    var selectedDates: [DateTaken] {
        let years = selectedYears.map(DateTaken.year)
        let months = selectedMonths.map(DateTaken.month)
        let days = selectedDays.map(DateTaken.day)

        return years + months + days
    }

    var selectedAlbums: [Album] {
        compactMap {
            if case .album(let a) = $0 { a } else { nil }
        }
    }

    var selectedEvents: [Event] {
        compactMap {
            if case .event(let e) = $0 { e } else { nil }
        }
    }

    var selectedPeople: [Person] {
        compactMap {
            if case .person(let a) = $0 { a } else { nil }
        }
    }

    var selectedCountries: [PlaceCountry] {
        compactMap {
            if case .placeCountry(let t) = $0 { t } else { nil }
        }
    }
    var selectedLocalities: [PlaceLocality] {
        compactMap {
            if case .placeLocality(let t) = $0 { t } else { nil }
        }
    }
    var selectedPlaces: [Place] {
        let countries = selectedCountries.map(Place.country)
        let localities = selectedLocalities.map(Place.locality)

        return countries + localities
    }

    var canEditOrDeleteSelection: Bool {
        selectedTags.count > 0 && selectedFilters.count == 0
    }
    var canEditSelection: Bool {
        selectedTags.count == 1 && selectedFilters.count == 0
    }
    var canDeleteSelection: Bool {
        selectedTags.count == 1 && selectedFilters.count == 0
    }
    var canDeleteManySelection: Bool {
        selectedTags.count > 1 && selectedFilters.count == 0
    }
}
