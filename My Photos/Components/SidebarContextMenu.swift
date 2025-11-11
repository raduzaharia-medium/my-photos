import SwiftUI

struct SidebarContextMenu: View {
    @Environment(PresentationState.self) private var presentationState
    @State private var deleteTagConfirmationPresented: Bool = true

    let current: SidebarItem

    private var photoFilter: Set<SidebarItem> { presentationState.photoFilter }
    private var all: Set<SidebarItem> { photoFilter.union([current]) }
    private var show: Bool { all.allSatisfy(\.self.editable) }

    var body: some View {
        let isCurrentInSelection = photoFilter.contains(current)
        if !show {
            EmptyView()
        } else if isCurrentInSelection && photoFilter.count > 1 {
            Button(role: .destructive) {
                FilterIntents.requestDelete(Array(photoFilter))
            } label: {
                Label("Delete All", systemImage: "trash")
            }
        } else {
            Button {
                if case .album(let album) = current {
                    AlbumIntents.requestEdit(album)
                } else if case .event(let event) = current {
                    EventIntents.requestEdit(event)
                } else if case .person(let person) = current {
                    PersonIntents.requestEdit(person)
                } else if case .tag(let tag) = current {
                    TagIntents.requestEdit(tag)
                }
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                if case .album(let album) = current {
                    AlbumIntents.requestDelete(album)
                } else if case .event(let event) = current {
                    EventIntents.requestDelete(event)
                } else if case .person(let person) = current {
                    PersonIntents.requestDelete(person)
                } else if case .tag(let tag) = current {
                    TagIntents.requestDelete(tag)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
