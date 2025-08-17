//
//  DetailView.swift
//  My Photos
//
//  Created by Radu Zaharia on 17.08.2025.
//

import SwiftData
import SwiftUI

enum DetailTab: String, CaseIterable, Identifiable {
    case photos = "Photos"
    case map = "Map"

    var id: String { rawValue }
}

struct DetailView: View {
    @State private var tab: DetailTab = .photos
    let tagID: PersistentIdentifier

    var body: some View {
        Group {
            switch tab {
            case .photos: PhotosView(tagID: tagID)
            case .map: PhotosView(tagID: tagID)
            }
        }
        .toolbar {
            ToolbarItem {
                Picker(
                    "Tab",
                    selection: Binding($tab)
                ) {
                    ForEach(DetailTab.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .help("Change how this tag is displayed")
            }
        }
    }
}
