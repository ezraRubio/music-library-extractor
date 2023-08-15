//
//  Song.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 14/08/2023.
//

import Foundation
import AppKit

struct Song: Codable, Identifiable {
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
    
    private enum CodingKeys: Int, CodingKey {
        case title = 0
        case artist = 1
        case album = 2
        case genre = 3
        case totalTime = 4
        case trackNumber = 5
        case sampleRate = 6
        case purchased = 7
        case releaseDate = 8
        case releaseYear = 9
    }
}
