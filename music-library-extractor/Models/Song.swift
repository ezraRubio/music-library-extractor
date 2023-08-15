//
//  Song.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 14/08/2023.
//

import Foundation
import AppKit

struct Song: Codable, Identifiable {
    let title: String
    let artist: String
    let album: String
    let genre: String
    let totalTime: Int
    let trackNumber: Int
    let sampleRate: Int
    let purchased: Bool
    let releaseDate: Date
    let releaseYear: Int
    
    var id = UUID()
}
