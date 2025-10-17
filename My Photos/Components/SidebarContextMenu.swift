import SwiftUI

private enum SelectionMode: Equatable {
    case none
    case singleTag(Tag)
    case singleAlbum(Album)
    case multipleTags([Tag])
    case multipleAlbums([Album])
}

extension Set where Element == SidebarItem {
    fileprivate var selectionMode: SelectionMode {
        guard selectedFilters.isEmpty else { return .none }

        let nonTagOrAlbumItems = self.filter { item in
            switch item {
            case .tag:
                return false
            case .album:
                return false
            default:
                return true
            }
        }
        guard nonTagOrAlbumItems.isEmpty else { return .none }

        if !selectedTags.isEmpty && selectedAlbums.isEmpty {
            switch selectedTags.count {
            case 0:
                return .none
            case 1:
                return .singleTag(selectedTags[0])
            default:
                return .multipleTags(selectedTags)
            }
        }

        if selectedTags.isEmpty && !selectedAlbums.isEmpty {
            switch selectedAlbums.count {
            case 0:
                return .none
            case 1:
                return .singleAlbum(selectedAlbums[0])
            default:
                return .multipleAlbums(selectedAlbums)
            }
        }

        return .none
    }
}

struct SidebarContextMenu: View {
    var selection: Set<SidebarItem>

    init(_ selection: Set<SidebarItem>) {
        self.selection = selection
    }

    var body: some View {
        menu(for: selection.selectionMode)
    }
}

@MainActor
@ViewBuilder
private func menu(for mode: SelectionMode) -> some View {
    switch mode {
    case .none:
        EmptyView()
    case .singleTag(let tag):
        tagMenu(tag)
    case .singleAlbum(let album):
        albumMenu(album)
    case .multipleTags(let tags):
        multipleTagsMenu(tags)
    case .multipleAlbums(let albums):
        multipleAlbumsMenu(albums)
    }
}

@MainActor
@ViewBuilder
private func tagMenu(_ tag: Tag) -> some View {
    Button {
        TagIntents.requestEdit(tag)
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    Button(role: .destructive) {
        TagIntents.requestDelete(tag)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func albumMenu(_ album: Album) -> some View {
    Button {
        AlbumIntents.requestEdit(album)
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    Button(role: .destructive) {
        AlbumIntents.requestDelete(album)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func multipleTagsMenu(_ tags: [Tag]) -> some View {
    Button(role: .destructive) {
        TagIntents.requestDelete(tags)
    } label: {
        Label("Delete \(tags.count) Tags", systemImage: "trash")
    }
}

@MainActor
@ViewBuilder
private func multipleAlbumsMenu(_ albums: [Album]) -> some View {
    Button(role: .destructive) {
        AlbumIntents.requestDelete(albums)
    } label: {
        Label("Delete \(albums.count) Albums", systemImage: "trash")
    }
}
