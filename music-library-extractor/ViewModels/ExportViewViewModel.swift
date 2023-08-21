//
//  ExportViewViewModel.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 14/08/2023.
//

import Foundation
import CodableCSV

class ExportViewViewModel: ObservableObject {
    @Published var includeTitle: Bool = false
    @Published var includeArtist: Bool = false
    @Published var includeAlbum: Bool = false
    @Published var includeGenre: Bool = false
    @Published var includeTotalTime: Bool = false
    @Published var includeTrackNumber: Bool = false
    @Published var includeSampleRate: Bool = false
    @Published var includePurchased: Bool = false
    @Published var includeReleaseDate: Bool = false
    @Published var includeReleaseYear: Bool = false
    
    
    func exportCSV(_ items: [Song]) -> Void {
        guard !items.isEmpty else {
            print("extract library first")
            return
        }

        let headers = declareCsvHeaders()
        let data = prepareData(headers, items)
        
        let fm = FileManager.default
        guard let url = fm.urls(for: .downloadsDirectory, in: .userDomainMask).first else { return }
        let filePath = url.appendingPathComponent("Results")

        do {
            if !fm.fileExists(atPath: filePath.relativePath) {
                try fm.createDirectory(at: filePath, withIntermediateDirectories: false)
            }

            let writer = try CSVWriter{$0.headers = headers}
            for dict in data {
                let row = headers.map { header in
                    dict[header] ?? ""
                }
                try writer.write(row: row)
            }
            try writer.endEncoding()
            let result = try writer.data()
            
            try result.write(to: filePath.appendingPathComponent("songs.csv"))
        } catch {
            print("Data encoding failed: \(error)")
        }

    }
    
    private func prepareData(_ headers: [String], _ items: [Song]) -> [[String : String]] {
        var tmpArrayDict: [[String : String]] = []
        
        for item in items {
            var tmpDict: [(String, String)] = []

            for header in headers {
                let propertyValue = getSongProperty(header, item)
                tmpDict.append((header, propertyValue))
            }

            tmpArrayDict.append(Dictionary(uniqueKeysWithValues: tmpDict))
        }
        
        return tmpArrayDict
    }
    
    private func getSongProperty(_ header: String, _ item: Song) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY"

        switch header {
        case "Title":
            return item.title
        case "Artist":
            return item.artist
        case "Album":
            return item.album
        case "Genre":
            return item.genre
        case "Length (ms)":
            return String(item.totalTime)
        case "Track #":
            return String(item.trackNumber)
        case "Sample Rate":
            return String(item.sampleRate)
        case "Purchased":
            return String(item.purchased)
        case "Release Date":
            return dateFormatter.string(from: item.releaseDate)
        case "Release Year":
            return String(item.releaseYear)
        default:
            return "unknown"
        }
    }
    
    private func declareCsvHeaders() -> [String] {
        var headers: [String] = []
        
        if self.includeTitle {
            headers.append("Title")
        }
        if self.includeArtist {
            headers.append("Artist")
        }
        if self.includeAlbum {
            headers.append("Album")
        }
        if self.includeGenre {
            headers.append("Genre")
        }
        if self.includeTotalTime {
            headers.append("Length (ms)")
        }
        if self.includeTrackNumber {
            headers.append("Track #")
        }
        if self.includeSampleRate {
            headers.append("Sample Rate")
        }
        if self.includePurchased {
            headers.append("Purchased")
        }
        if self.includeReleaseDate {
            headers.append("Release Date")
        }
        if self.includeReleaseYear {
            headers.append("Release Year")
        }
        
        return headers
    }
}
