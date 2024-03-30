//
//  FeedLoader.swift
//  NetworkSample
//
//  Created by Amir on 3/30/24.
//

import Foundation
import Combine

protocol HTTPClient {
    func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error>
}

extension URLSession: HTTPClient {
    struct InvalidHTTPResponseError: Error{}
    func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        return dataTaskPublisher(for: request)
            .tryMap({ result in
                guard
                    let httpResponse = result.response as? HTTPURLResponse else {
                    throw InvalidHTTPResponseError()
                }
                return(result.data, httpResponse)
            })
            .eraseToAnyPublisher()
    }
}

protocol TokenProvider {
    func tokenPublisher() -> AnyPublisher<AuthenticationJWTDTO, Error>
}

class AuthenticatedHTTPClientDecorator: HTTPClient {
    let client: HTTPClient
    let tokenProvider: TokenProvider
    init(client: HTTPClient, tokenProvider: TokenProvider) {
        self.client = client
        self.tokenProvider = tokenProvider
    }
    func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        return tokenProvider
            .tokenPublisher()
            .map { token in
                var signedRequest = request
                signedRequest.allHTTPHeaderFields?.removeValue(forKey: "Authorization")
                signedRequest.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
                return signedRequest
            }
            .flatMap(client.publisher)
            .eraseToAnyPublisher()
    }
}
