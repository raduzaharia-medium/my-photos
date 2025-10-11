import Foundation
import SwiftData

@Model
final class DateTakenYear: Identifiable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var year: Int

    @Relationship(inverse: \DateTakenMonth.year) var months: [DateTakenMonth] =
        []
    @Relationship var photos: [Photo] = []

    init(_ year: Int) {
        self.year = year
    }
}

@Model
final class DateTakenMonth: Identifiable {
    @Attribute(.unique) var id = UUID()
    var month: Int

    @Relationship var year: DateTakenYear
    @Relationship(inverse: \DateTakenDay.month) var days: [DateTakenDay] = []
    @Relationship var photos: [Photo] = []

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
    @Relationship var photos: [Photo] = []

    init(_ month: DateTakenMonth, _ day: Int) {
        self.day = day
        self.month = month
    }
}
