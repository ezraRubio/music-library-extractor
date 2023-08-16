//
//  ExportViewViewModel.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 14/08/2023.
//

import Foundation
import CodableCSV

class ExportViewViewModel: ObservableObject {
    @Published var includeTitle: Bool = true
    @Published var includeArtist: Bool = true
    @Published var includeAlbum: Bool = true
    @Published var includeGenre: Bool = true
    @Published var includeTotalTime: Bool = true
    @Published var includeTrackNumber: Bool = true
    @Published var includeSampleRate: Bool = true
    @Published var includePurchased: Bool = true
    @Published var includeReleaseDate: Bool = true
    @Published var includeReleaseYear: Bool = true
    
    
    func exportCSV(_ items: [Song]) -> Void {
        guard !items.isEmpty else {
            print("extract library first")
            return
        }
        

        let headers = declareCsvHeaders()
        let data = prepareData(headers, items)
        
        let fm = FileManager.default
        guard let url = fm.urls(for: .downloadsDirectory, in: .userDomainMask).first else { return }
        print("current directory: \(url))")
        let filePath = url.appendingPathComponent("Results")
        let fileData = "trololol, lulz".data(using: .utf8)
        print("file creation path: \(filePath.path)")


        do {
            try fm.createDirectory(at: filePath, withIntermediateDirectories: false)

            let writer = try CSVWriter{$0.headers = headers}
            for row in data {
                try writer.write(row: row.values)
            }
            try writer.endEncoding()
            let result = try writer.data()
            try result.write(to: filePath.appendingPathComponent("songs.csv"))
        } catch {
            print("Data encoding failed: \(error)")
        }

    }
    
    private func prepareData(_ headers: [String], _ items: [Song]) -> [[String : String]] {
        var tmpArrayDict: [[String : String]] = [[:]]
        
        for item in items {
            var tmpDict: [String : String] = [:]
            
            for header in headers {
                tmpDict[header] = getSongProperty(headers, header, item)
            }
            
            tmpArrayDict.append(tmpDict)
        }
        
        tmpArrayDict.removeFirst()
        return tmpArrayDict
    }
    
    private func getSongProperty(_ headers: [String], _ header: String, _ item: Song) -> String {
        let index = headers.firstIndex(of: header)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY"
        
        switch index {
        case 0:
            return item.title
        case 1:
            return item.artist
        case 2:
            return item.album
        case 3:
            return item.genre
        case 4:
            return String(item.totalTime)
        case 5:
            return String(item.trackNumber)
        case 6:
            return String(item.sampleRate)
        case 7:
            return String(item.purchased)
        case 8:
            return dateFormatter.string(from: item.releaseDate)
        case 9:
            return String(item.releaseYear)
        default:
            return "unkown"
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
