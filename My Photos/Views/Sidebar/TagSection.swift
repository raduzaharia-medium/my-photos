import SwiftUI

struct TagSection: View {
    let title: String
    let tags: [Tag]

    init(
        _ title: String,
        _ tags: [Tag],
    ) {
        self.title = title
        self.tags = tags
    }

    var body: some View {
        Section(title) {
            ForEach(tags, id: \.persistentModelID) { tag in
                TagRow(tag)
            }
        }
    }
}
