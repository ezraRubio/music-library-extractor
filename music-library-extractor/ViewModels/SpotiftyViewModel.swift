//
//  SpotiftyViewModel.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 03/01/2024.
//

import Foundation
import SpotifyWebAPI
import Combine
import KeychainAccess

@MainActor
class SpotiftyViewModel: ObservableObject {
    @Published var isAuthorized = false
    @Published var currentUser: SpotifyUser? = nil
    @Published var itemsToUserSpotify: [SpotifyLibItem] = []
    @Published var isDoneProcessingItems: Bool = true
    @Published var isDoneAddingItemsToSpotify: Bool = false
    var listUriToAdd: [String] = []
    
    let keychain = Keychain(service: "com.ezra-rubio.music-library-extractor")
    let authorizationManagerKey = "authorizationManager"
    
    private static let clientId: String = {
        if let clientId = Bundle.main.infoDictionary?["CLIENT_ID"] as? String {
            return clientId
        }
        fatalError("Could not find value of 'CLIENT_ID'")
    }()
    
    private static let clientSecret: String = {
        if let clientSecret = Bundle.main.infoDictionary?["CLIENT_SECRET"] as? String {
            return clientSecret
        }
        fatalError("Could not find value of 'CLIENT_SECRET'")
    }()
    
    private static let loginCallbackURL = URL(
        string: "music-library-extractor://callback"
    )!
    
    
    //! codeVerifier, codeChallenge and state should be regenerated before any reauthorization / after need for refresh token
    private static let codeVerifier = String.randomURLSafe(length: 128)
    private static let codeChallenge = String.makeCodeChallenge(codeVerifier: codeVerifier)

    // optional, but strongly recommended
    let state = String.randomURLSafe(length: 128)
    
    private let spotify = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowPKCEManager(
            clientId: SpotiftyViewModel.clientId
        )
    )
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.spotify.apiRequestLogger.logLevel = .trace
        
        self.spotify.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)
        
        self.spotify.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)
        
        if let authManagerData = keychain[data: self.authorizationManagerKey] {
            
            do {
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowPKCEManager.self,
                    from: authManagerData
                )
  
                self.spotify.authorizationManager = authorizationManager
                
            } catch {
                print("could not decode authorizationManager from data:\n\(error)")
            }
        }
        else {
            print("did NOT find authorization information in keychain")
        }
    }
    
    func authorizationManagerDidChange() {
        self.isAuthorized = self.spotify.authorizationManager.isAuthorized()
        
        self.retrieveCurrentUser()
        
        do {
            // Encode the authorization information to data.
            let authManagerData = try JSONEncoder().encode(
                self.spotify.authorizationManager
            )
            
            // Save the data to the keychain.
            self.keychain[data: self.authorizationManagerKey] = authManagerData
            
        } catch {
            print(
                "couldn't encode authorizationManager for storage " +
                    "in keychain:\n\(error)"
            )
        }
    }
    
    func authorizationManagerDidDeauthorize() {
        self.isAuthorized = false
        
        self.currentUser = nil
        
        do {
            try self.keychain.remove(self.authorizationManagerKey)
        } catch {
            print(
                "couldn't remove authorization manager " +
                "from keychain: \(error)"
            )
        }
    }
    
    func retrieveCurrentUser() {
        guard self.currentUser == nil else { return }
        guard self.isAuthorized else { return }
        
        self.spotify.currentUserProfile()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("couldn't retrieve current user: \(error)")
                        self.isAuthorized = false
                        self.currentUser = nil
                    }
                },
                receiveValue: { user in
                    self.currentUser = user
                }
            )
            .store(in: &cancellables)
    }
    
    func logInSpotify() -> URL {
        let authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: SpotiftyViewModel.loginCallbackURL,
            codeChallenge: SpotiftyViewModel.codeChallenge,
            state: state,
            scopes: [
                .playlistModifyPrivate,
                .userModifyPlaybackState,
                .playlistReadCollaborative,
                .userReadPlaybackPosition,
                .userLibraryRead,
                .userLibraryModify,
            ]
        )!
        return authorizationURL
    }
    
    func refreshToken(_ url: URL) {
        spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            codeVerifier: SpotiftyViewModel.codeVerifier,
            state: state
        )
        .sink(receiveCompletion: { completion in
            switch completion {
                case .finished:
                    print("successfully authorized")
                case .failure(let error):
                    if let authError = error as? SpotifyAuthorizationError, authError.accessWasDenied {
                        print("The user denied the authorization request")
                    }
                    else {
                        print("couldn't authorize application: \(error)")
                    }
            }
        })
        .store(in: &cancellables)
    }
    
    func processExtractedLibraryItems(mediaItems: [Song]) async {
        for item: Song in mediaItems {
            isDoneProcessingItems = false
            let results = await findMediaItemInSpotify(mediaItem: item)
            let filteredUri = await filterSpotifySearchResults(uris: results, item: item)
            let isItemInUserSpotifyLibrary = await checkMediaItemInUserSpotifyLibrary(uri: filteredUri)

            let spotifyItem = SpotifyLibItem(title: item.title, artist: item.artist, album: item.album, onUserLibrary: isItemInUserSpotifyLibrary, notFoundOnSpotify: filteredUri.isEmpty, spotifyUri: filteredUri , isSelected: false)
            itemsToUserSpotify.append(spotifyItem)
        }
        isDoneProcessingItems = true
    }
    
    func findMediaItemInSpotify(mediaItem: Song) async -> [String] {
        let searchPublisherValues = spotify.search(query: "\(mediaItem.title) \(mediaItem.artist) \(mediaItem.album)", categories: [IDCategory.track, IDCategory.artist, IDCategory.album]).values
        var results: [String] = []
        
        do {
            for try await searchValue in searchPublisherValues {
                searchValue.tracks?.items.forEach { results.append($0.uri ?? "") }
            }
        } catch {
            print("Error while searching on spotify: \(error)")
        }
        
        return results
    }
    
    func filterSpotifySearchResults(uris: [String], item: Song) async -> String {
        var filteredUri: String = ""
        for uri in uris {
            let tracksPublisherValues = spotify.track(uri).values
            do {
                for try await foundItem in tracksPublisherValues {
                    if foundItem.name.lowercased() == item.title.lowercased() && foundItem.album?.name.lowercased() == item.album.lowercased() && foundItem.artists?.first?.name.lowercased() == item.artist.lowercased() {
                        filteredUri = uri
                        return filteredUri
                    }
                }
            } catch {
                print("error while checking items found on spotify library: ", error)
            }
        }
        return filteredUri
    }

    func checkMediaItemInUserSpotifyLibrary(uri: String) async -> Bool {
        var itemInLibrary: Bool  = false
        do {
            for try await item in spotify.currentUserSavedTracksContains([uri]).values {
                itemInLibrary = item.first!
            }
        } catch {
            print("error while checking inside user's library: \(error)")
        }
        return itemInLibrary
    }
    
    func processSelectedItemsIntoSpotifyLibrary() {
        for item: SpotifyLibItem in itemsToUserSpotify {
            if item.isSelected {
                listUriToAdd.append(item.spotifyUri)
            }
        }
        spotify.saveTracksForCurrentUser(listUriToAdd)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        DispatchQueue.main.async{
                            self.isDoneAddingItemsToSpotify = true
                        }
                        
                    case .failure(let error):
                        print("Error while adding to library: ", error)
                }
            })
            .store(in: &cancellables)
    }
}
