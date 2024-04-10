//
//  SpotifyLibItem.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 18/03/2024.
//

import Foundation

struct SpotifyLibItem: Identifiable, Equatable {
    var title: String
    var artist: String
    var album: String
    var onUserLibrary: Bool
    var notFoundOnSpotify: Bool
    var spotifyUri: String
    var isSelected: Bool
    
    var formattedNotFoundOnSpotify: String {
        notFoundOnSpotify ? "Not Found On Spotify" : "Found on Spotify"
    }
    var formattedOnUserLibrary: String {
        onUserLibrary ? "Already on Spotify Library" : "Not yet on Spotify Library"
    }
    var id = UUID()
}
