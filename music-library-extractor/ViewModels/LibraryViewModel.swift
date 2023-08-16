//
//  LibraryViewModel.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 13/08/2023.
//

import Foundation
import iTunesLibrary
import AppKit

class LibraryViewModel: ObservableObject {
    @Published var songs : [String] = []
    @Published var mediaItems : [Song] = []
    
    func generateSongList(completion: @escaping () -> Void) -> Void {
        do {
            let library = try ITLibrary(apiVersion: "1.0")
            var songArray = [String]()

            for item: ITLibMediaItem in library.allMediaItems {
                let mediaItem = Song(
                    title: item.title,
                    artist: item.artist?.name ?? "unknown",
                    album: item.album.title ?? "unknown",
                    genre: item.genre,
                    totalTime: item.totalTime,
                    trackNumber: item.trackNumber,
                    sampleRate: item.sampleRate,
                    purchased: item.isPurchased,
                    releaseDate: item.releaseDate ?? Date(),
                    releaseYear: item.year
                )
                self.mediaItems.append(mediaItem)
                
                let song = "\(item.title) from \(item.album.title ?? "unknown") by \(item.artist?.name ?? "unknown")"
                songArray.append(song)
            }

            DispatchQueue.main.async {
                self.songs = songArray
                completion()
            }

        } catch {
            print ("Error Initializing iTunes Library: \(error.localizedDescription)")
        }
    }
}
