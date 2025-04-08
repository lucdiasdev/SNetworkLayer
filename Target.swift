//
//  Target.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

public protocol Target {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headerParamaters: [String: String]? { get }
    var task: Task { get }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum ParameterEncoding {
    case httpBody
    case query
}

public enum Task {
    case requestDefault
    case bodyParametersEncodable(Encodable)
    case bodyParameters(_ parameters: [String: Any], encodingParameters: ParameterEncoding)
}

public extension Target {
    var baseURL: URL {
        guard let url = URL(string: "http://localhost:3000") else {
            assertionFailure("Invalid static URL string: https://pokeapi.co/api/v2/")
            return URL(fileURLWithPath: "https://pokeapi.co/api/v2/")
        }
        return url
    }
}
