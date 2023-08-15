//
//  ExportViewViewModel.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 14/08/2023.
//

import Foundation

class ExportViewViewModel: ObservableObject {
    @Published var includeTitle: Bool = false
    @Published var includeArtist: Bool = false
    @Published var includeAlbum: Bool = false
    @Published var includeGenre: Bool = false
    @Published var includeTotalTime: Bool = false
    @Published var includeTrackNumber: Bool = false
    @Published var includeSampleRate: Bool = false
    @Published var includeArtwork: Bool = false
    @Published var includePurchased: Bool = false
    @Published var includeReleaseDate: Bool = false
    @Published var includeReleaseYear: Bool = false
    
}
