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

class SpotiftyViewModel: ObservableObject {
    @Published var isAuthorized = false
    @Published var currentUser: SpotifyUser? = nil
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
                print("found authorization information in keychain")
  
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
        
        print(
            "Spotify.authorizationManagerDidChange: isAuthorized:",
            self.isAuthorized
        )
        
        self.retrieveCurrentUser()
        
        do {
            // Encode the authorization information to data.
            let authManagerData = try JSONEncoder().encode(
                self.spotify.authorizationManager
            )
            
            // Save the data to the keychain.
            self.keychain[data: self.authorizationManagerKey] = authManagerData
            print("did save authorization manager to keychain")
            
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
            print("did remove authorization manager from keychain")
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
                .userReadPlaybackPosition
            ]
        )!
        print("sent to authorize: \(authorizationURL)")
        return authorizationURL
    }
    
    func refreshToken(_ url: URL) {
        print("inside refresh token, received url: \(url)")
        spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            // Must match the code verifier that was used to generate the
            // code challenge when creating the authorization URL.
            codeVerifier: SpotiftyViewModel.codeVerifier,
            // Must match the value used when creating the authorization URL.
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
}
