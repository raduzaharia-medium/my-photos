import Foundation
import SwiftData

@Model
final class DateTakenYear: Identifiable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var year: Int

    @Relationship(deleteRule: .cascade, inverse: \DateTakenMonth.year)
    var months: [DateTakenMonth] =
        []
    @Relationship(inverse: \Photo.dateTakenYear) var photos: [Photo] = []

    init(_ year: Int) {
        self.year = year
    }
}

@Model
final class DateTakenMonth: Identifiable {
    @Attribute(.unique) var id = UUID()
    var month: Int

    @Relationship var year: DateTakenYear
    @Relationship(deleteRule: .cascade, inverse: \DateTakenDay.month) var days:
        [DateTakenDay] = []
    @Relationship(inverse: \Photo.dateTakenMonth) var photos: [Photo] = []

    init(_ year: DateTakenYear, _ month: Int) {
        precondition((1...12).contains(month), "Month must be 1...12")

        self.month = month
        self.year = year
    }
}

@Model
final class DateTakenDay: Identifiable {
    @Attribute(.unique) var id = UUID()

    var day: Int

    @Relationship var month: DateTakenMonth
    @Relationship(inverse: \Photo.dateTakenDay) var photos: [Photo] = []

    init(_ month: DateTakenMonth, _ day: Int) {
        self.day = day
        self.month = month
    }
}

enum DateTaken: Hashable {
    case year(DateTakenYear)
    case month(DateTakenMonth)
    case day(DateTakenDay)
}
