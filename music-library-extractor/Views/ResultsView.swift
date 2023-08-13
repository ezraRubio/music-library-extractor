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
            List(libraryViewModel.songs, id: \.self) {
                song in Text(song)
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
