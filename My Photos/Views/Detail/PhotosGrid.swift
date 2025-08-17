//
//  PhotosView.swift
//  My Photos
//
//  Created by Radu Zaharia on 17.08.2025.
//

import SwiftData
import SwiftUI

struct PhotosView: View {
    let tag: Tag?

    var body: some View {
        if tag == nil {
            ContentUnavailableView(
                "Select a tag",
                systemImage: "tag.slash",
                description: Text("Let's browse all photos.")
            )
        } else {
            Text(tag?.name ?? "Unknown Tag")
        }
    }
}
