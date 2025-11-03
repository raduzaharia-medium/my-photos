import Foundation
import SwiftData

@Model
final class DateTakenYear: Identifiable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String
    @Attribute(.unique) var year: Int

    @Relationship(deleteRule: .cascade, inverse: \DateTakenMonth.year)
    var months: [DateTakenMonth] = []
    @Relationship(inverse: \Photo.dateTakenYear) var photos: [Photo] = []

    init(_ year: Int) {
        self.year = year
        self.key = DateTakenYear.key(year)
    }

    static func == (left: DateTakenYear, right: DateTakenYear) -> Bool {
        left.key == right.key
    }

    static func key(_ year: Int) -> String { "\(year)" }
}

@Model
final class DateTakenMonth: Identifiable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String

    var month: Int

    @Relationship var year: DateTakenYear
    @Relationship(deleteRule: .cascade, inverse: \DateTakenDay.month) var days:
        [DateTakenDay] = []
    @Relationship(inverse: \Photo.dateTakenMonth) var photos: [Photo] = []

    init(_ year: DateTakenYear, _ month: Int) {
        precondition((1...12).contains(month), "Month must be 1...12")

        self.month = month
        self.year = year
        self.key = DateTakenMonth.key(year, month)
    }

    static func == (left: DateTakenMonth, right: DateTakenMonth) -> Bool {
        left.key == right.key
    }

    static func key(_ year: DateTakenYear, _ month: Int) -> String {
        "\(year.key)-\(String(format: "%02d", month))"
    }
    static func key(_ year: Int, _ month: Int) -> String {
        "\(DateTakenYear.key(year))-\(String(format: "%02d", month))"
    }
}

@Model
final class DateTakenDay: Identifiable, Equatable {
    @Attribute(.unique) var id = UUID()
    @Attribute(.unique) var key: String

    var day: Int

    @Relationship var month: DateTakenMonth
    @Relationship(inverse: \Photo.dateTakenDay) var photos: [Photo] = []

    init(_ month: DateTakenMonth, _ day: Int) {
        self.day = day
        self.month = month
        self.key = DateTakenDay.key(month, day)
    }

    static func == (left: DateTakenDay, right: DateTakenDay) -> Bool {
        left.key == right.key
    }

    static func key(_ month: DateTakenMonth, _ day: Int) -> String {
        "\(month.key)-\(String(format: "%02d", day))"
    }
    static func key(_ year: Int, _ month: Int, _ day: Int) -> String {
        "\(DateTakenMonth.key(year, month))-\(String(format: "%02d", day))"
    }
}

enum DateTaken: Hashable {
    case year(DateTakenYear)
    case month(DateTakenMonth)
    case day(DateTakenDay)
}

extension DateTakenYear {
    static let icon: String = "calendar"
}

extension DateTakenMonth {
    static let icon: String = "calendar"
}

extension DateTakenDay {
    static let icon: String = "calendar"
}
