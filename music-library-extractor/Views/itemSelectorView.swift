//
//  itemSelectorView.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 10/04/2024.
//

import SwiftUI

struct itemSelectorView: View {
    var item: SpotifyLibItem
    var index: Int
    @Binding var isSelected: Bool
    var body: some View {
        Toggle("", isOn: $isSelected)
        .disabled(item.notFoundOnSpotify || item.onUserLibrary)
    }
}
