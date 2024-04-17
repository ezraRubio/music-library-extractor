//
//  ResultsView.swift
//  music-library-extractor
//
//  Created by Ezra Rubio on 10/08/2023.
//

import SwiftUI

struct ResultsView: View {
    @ObservedObject var libraryViewModel: LibraryViewModel
    @State private var sortOrder = [KeyPathComparator(\Song.title), KeyPathComparator(\Song.artist), KeyPathComparator(\Song.album), KeyPathComparator(\Song.genre)]

    var body: some View {
        if !libraryViewModel.mediaItems.isEmpty {
            Table(libraryViewModel.mediaItems, sortOrder: $sortOrder) {
                TableColumn("Title", value: \.title)
                TableColumn("Artist", value: \.artist)
                TableColumn("Album", value: \.album)
                TableColumn("Genre", value: \.genre)
            }
            .onChange(of: sortOrder) {
                libraryViewModel.mediaItems.sort(using: $0)
            }
        } else {
            Text("No library extracted yet.")
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(libraryViewModel: LibraryViewModel())
    }
}
