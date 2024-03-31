//
//  CountryListService.swift
//  NetworkSample
//
//  Created by Amir on 3/31/24.
//

import Foundation
import Combine

class CountryListService {
    let httpClient: AuthenticatedHTTPClientDecorator
    
    internal init(HTTPClient: AuthenticatedHTTPClientDecorator) {
        self.httpClient = HTTPClient
    }
    
    func loadCountries() -> AnyPublisher<[CountryDTO], Error> {
        return httpClient.publisher(URLRequest(url: URL(string: "https:\\any-url")!))
            .tryMap(CountryListMapper.map)
            .eraseToAnyPublisher()
    }
}
