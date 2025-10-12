import Foundation

struct DateTakenParser {
    private let dateTaken: Date?

    init(_ dateTaken: Date?) {
        self.dateTaken = dateTaken
    }

    var dateTakenYear: DateTakenYear? {
        guard let dateTaken else { return nil }
        
        let year = Calendar.current.component(.year, from: dateTaken)
        return DateTakenYear(year)
    }
    var dateTakenMonth: DateTakenMonth? {
        guard let dateTaken else { return nil }
        guard let dateTakenYear else { return nil }

        let month = Calendar.current.component(.month, from: dateTaken)
        return DateTakenMonth(dateTakenYear, month)
    }
    var dateTakenDay: DateTakenDay? {
        guard let dateTaken else { return nil }
        guard let dateTakenMonth else { return nil }

        let day = Calendar.current.component(.day, from: dateTaken)
        return DateTakenDay(dateTakenMonth, day)
    }
}
