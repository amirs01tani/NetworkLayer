//
//  AuthenticatedHTTPClientSession.swift
//  NetworkSample
//
//  Created by Amir on 3/31/24.
//

import Foundation
import Combine

protocol TokenProvider {
    func tokenPublisher() -> AnyPublisher<String, Error>
}

class AuthenticatedHTTPClientDecorator: HTTPClient {
    let client: HTTPClient
    let tokenProvider: TokenProvider
    var needAuth: (()->Void)?
    
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
                signedRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return signedRequest
            }
            .flatMap(client.publisher)
            .handleEvents(receiveCompletion: { [needAuth] completion in
                if case let Subscribers.Completion<Error>.failure(error) = completion,
                   case APIErrorHandler.tokenExpired? = error as? APIErrorHandler {
                    needAuth?()
                }
            }).eraseToAnyPublisher()
    }
}
