import SwiftUI

struct FiltersSection: View {
    var body: some View {
        Section("Filters") {
            ForEach(Filter.allCases, id: \.self) { filter in
                SidebarRow(.filter(filter)).tag(filter)
            }
        }
    }
}
