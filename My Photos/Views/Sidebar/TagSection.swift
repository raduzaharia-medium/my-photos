import SwiftUI

struct TagSection: View {
    let title: String
    let tags: [Tag]

    let onEdit: (Tag) -> Void
    let onDelete: (Tag) -> Void

    init(
        _ title: String,
        _ tags: [Tag],
        onEdit: @escaping (Tag) -> Void,
        onDelete: @escaping (Tag) -> Void
    ) {
        self.title = title
        self.tags = tags
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    var body: some View {
        Section(title) {
            ForEach(tags, id: \.persistentModelID) { tag in
                TagRow(
                    tag,
                    onEdit: onEdit,
                    onDelete: onDelete
                )
            }
        }
    }
}
