//
//  ToSpotifyView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 18/03/2024.
//

import SwiftUI

struct ToSpotifyView: View {
    @ObservedObject var spotifyViewModel = SpotiftyViewModel()
    
    var body: some View {
        Table(spotifyViewModel.itemsToUserSpotify) {
            TableColumn("Title", value: \.title)
            TableColumn("Artist", value: \.artist)
            TableColumn("Album", value: \.album)
            TableColumn("Not Found on Spotify", value: \.formattedNotFoundOnSpotify)
            TableColumn("Already in your Spotify Library", value: \.formattedOnUserLibrary)
            TableColumn("Add to Spotify Library") { item in
                if let index = self.spotifyViewModel.itemsToUserSpotify.firstIndex(of: item) {
                    itemSelectorView(item: item, index: index, isSelected: $spotifyViewModel.itemsToUserSpotify[index].isSelected)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ToSpotifyView(spotifyViewModel: SpotiftyViewModel())
}
