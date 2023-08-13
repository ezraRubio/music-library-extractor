//
//  LibraryViewModel.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 13/08/2023.
//

import Foundation
import iTunesLibrary

class LibraryViewModel: ObservableObject {
    @Published var songs : [String] = []
    
    func generateSongList(completion: @escaping () -> Void){
        do {
            let library = try ITLibrary(apiVersion: "1.0")
            var songArray = [String]()

            for item: ITLibMediaItem in library.allMediaItems {
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
