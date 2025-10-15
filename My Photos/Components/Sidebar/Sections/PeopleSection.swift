import SwiftData
import SwiftUI

struct PeopleSection: View {
    @Query(sort: \Person.key) private var people: [Person]

    var body: some View {
        Section("People") {
            ForEach(people) { person in
                SidebarRow(.person(person)).tag(person)
            }
        }
    }
}
