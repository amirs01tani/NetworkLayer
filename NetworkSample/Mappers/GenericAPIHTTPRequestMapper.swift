//
//  GenericAPIHTTPRequestMapper.swift
//  NetworkSample
//
//  Created by Amir on 3/31/24.
//

import Foundation

struct GenericAPIHTTPRequestMapper {
    static func map<T>(data: Data, response: HTTPURLResponse) throws -> T where T: Decodable {
        if (200..<300) ~= response.statusCode {
            return try JSONDecoder().decode(T.self, from: data)
        } else if response.statusCode == 401 {
            throw APIErrorHandler.tokenExpired
        } else {
            if let error = try? JSONDecoder().decode(ApiErrorDTO.self, from: data) {
                throw APIErrorHandler.customApiError(error)
            } else {
                throw APIErrorHandler.emptyErrorWithStatusCode(response.statusCode.description)
            }
        }
    }
}
