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

public enum HTTPMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum EncodeParameters {
    case http
    case query
    case bodyWithQuery
}

public enum Task {
    case requestDefault
    case requestBodyEncodable(Encodable)
    case requestParameters(parameters: [String: Any], encodeParameters: EncodeParameters)
}
