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
        let filePath = NSHomeDirectory() + "/Desktop/Songs.csv"
        let isFileCreated = createFile(filePath)
        let encoder = CSVEncoder { $0.headers = headers }

        do {
            if isFileCreated {
//                try encoder.encode(<#T##value: Encodable##Encodable#>, into: <#T##Data.Type#>)
            } else {
                print("there was an error creating the file.")
            }
        } catch {
            print("Data encoding failed: \(error)")
        }

    }
    
    private func createFile(_ filePath: String) -> Bool {
        return FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
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
