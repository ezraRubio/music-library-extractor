//
//  SpotiftyViewModel.swift
//  music-library-extractor
//
//  Created by עזרא רוביו on 03/01/2024.
//

import Foundation
import SpotifyWebAPI
import Combine

class SpotiftyViewModel: ObservableObject {
    
    private static let clientId: String = {
        if let clientId = ProcessInfo.processInfo
                .environment["CLIENT_ID"] {
            return clientId
        }
        fatalError("Could not find 'CLIENT_ID' in environment variables")
    }()
    
    private static let clientSecret: String = {
        if let clientSecret = ProcessInfo.processInfo
                .environment["CLIENT_SECRET"] {
            return clientSecret
        }
        fatalError("Could not find 'CLIENT_SECRET' in environment variables")
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
