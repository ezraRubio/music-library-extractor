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
    @Published var includeArtist: Bool = false
    @Published var includeAlbum: Bool = false
    @Published var includeGenre: Bool = false
    @Published var includeTotalTime: Bool = false
    @Published var includeTrackNumber: Bool = false
    @Published var includeSampleRate: Bool = false
    @Published var includePurchased: Bool = false
    @Published var includeReleaseDate: Bool = false
    @Published var includeReleaseYear: Bool = false
    @Published var fileName: String = ""
    @Published var error: String = ""
    @Published var isFileCreated: Bool = false
    
    
    func exportCSV(_ items: [Song]) -> Void {
        guard !items.isEmpty else {
            self.error = "extract library first"
            return
        }
        
        guard isNoFieldSelected() else {
            return
        }
        
        guard isValidFileName(fileName) else {
            return
        }
        
        self.isFileCreated = false
        self.error = ""
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
            
            try result.write(to: filePath.appendingPathComponent("\(fileName).csv"))
            self.isFileCreated = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.isFileCreated = false
            }
            self.fileName = ""
        } catch {
            self.isFileCreated = false
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
    
    private func isValidFileName(_ name: String) -> Bool {
        if name.isEmpty {
            self.error = "File name cannot be empty"
            return false
        }
        
        let disallowedCharacters = CharacterSet(charactersIn: ":")
        if name.rangeOfCharacter(from: disallowedCharacters) != nil {
            self.error = "Use only valid character for the file name"
            return false
        }
        
        let disallowedFileNames = ["Desktop", "Library", "Applications", "Downloads"]
        if disallowedFileNames.contains(name) {
            self.error = "Do not include directory name to the file name"
            return false
        }
        
        return true
    }
    
    private func isNoFieldSelected() -> Bool {
        if (!self.includeTitle && !self.includeArtist && !self.includeAlbum && !self.includeGenre && !self.includeTotalTime && !self.includeTrackNumber && !self.includeSampleRate && !self.includePurchased && !self.includeReleaseDate && !self.includeReleaseYear) {
            self.error = "Please select at least on field of data to be included"
            return false
        }
        
        return true
    }
}
