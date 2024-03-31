//
//  CountryListMapper.swift
//  NetworkSample
//
//  Created by Amir on 3/31/24.
//

import Foundation

struct CountryListMapper {
    static func map(data: Data, response: HTTPURLResponse) throws -> [CountryDTO] {
        if response.statusCode == 401 {
            throw APIErrorHandler.tokenExpired
        }
        if let error = try? JSONDecoder() .decode(ApiErrorDTO.self, from: data) {
            throw APIErrorHandler.customApiError(error)
        } else {
            throw APIErrorHandler.emptyErrorWithStatusCode(response.statusCode.description)
        }
    }
}
