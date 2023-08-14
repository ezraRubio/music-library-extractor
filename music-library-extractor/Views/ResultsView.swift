//
//  ResultsView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 10/08/2023.
//

import SwiftUI

struct ResultsView: View {
    @ObservedObject var libraryViewModel: LibraryViewModel

    var body: some View {
        if !libraryViewModel.songs.isEmpty {
            Table(libraryViewModel.mediaItems) {
                TableColumn("Title", value: \.title)
                TableColumn("Artist", value: \.artist)
                TableColumn("Album", value: \.album)
                TableColumn("Genre", value: \.genre)
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
