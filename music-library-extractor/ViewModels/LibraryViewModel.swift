//
//  LibraryViewModel.swift
//  music-library-extractor
//
//  Created by Ezra Rubio on 13/08/2023.
//

import Foundation
import iTunesLibrary
import AppKit
import CodableCSV

class LibraryViewModel: ObservableObject {
    @Published var songs : [String] = []
    @Published var mediaItems : [Song] = []
    
    func generateSongListFromItunes(completion: @escaping () -> Void) -> Void {
        self.mediaItems = []
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
    
    func generateSongListFromCSV(_ file: URL, completion: @escaping () -> Void) -> Void {
        self.mediaItems = []
        do {
            let result = try CSVReader.decode(input: file)
            let headers = result.rows[0]
            
            for row in result.rows {
                if row==headers { continue }
                self.mediaItems.append(processRow(row, headers))
            }
            DispatchQueue.main.async{
                completion()
            }
        } catch {
            print("Error importing csv file: \(error.localizedDescription)")
        }
    }
    
    private func processRow(_ row: [String], _ headers: [String]) -> Song {
        var item = Song(title: "", artist: "", album: "", genre: "", totalTime: 0, trackNumber: 0, sampleRate: 0, purchased: false, releaseDate: Date(), releaseYear: 0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yy"

        for header in headers {
            switch header {
            case "Title":
                item.title = row[0]
            case "Artist":
                item.artist = row[1]
            case "Album":
                item.album = row[2]
            case "Genre":
                item.genre = row[3]
            case "Length (ms)":
                item.totalTime = Int(row[4]) ?? 0
            case "Track #":
                item.trackNumber = Int(row[5]) ?? 0
            case "Sample Rate":
                item.sampleRate = Int(row[6]) ?? 0
            case "Purchased":
                item.purchased = getStringBooleanValue(row[7])
            case "Release Date":
                item.releaseDate = dateFormatter.date(from:row[8]) ?? Date()
            case "Release Year":
                item.releaseYear = Int(row[9]) ?? 1111
            default:
                break
            }
        }
        
        return item
    }
    
    private func getStringBooleanValue(_ value: String) -> Bool {
        var booleanValue: Bool = false
        switch value {
        case "true":
            booleanValue = true
        case "false":
            booleanValue = false
        default:
            break
        }
        return booleanValue
    }
}
