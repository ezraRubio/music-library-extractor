//
//  Song.swift
//  music-library-extractor
//
//  Created by Ezra Rubio on 14/08/2023.
//

import Foundation
import AppKit

struct Song: Identifiable {
    var title: String
    var artist: String
    var album: String
    var genre: String
    var totalTime: Int
    var trackNumber: Int
    var sampleRate: Int
    var purchased: Bool
    var releaseDate: Date
    var releaseYear: Int
    
    var id = UUID()
}
