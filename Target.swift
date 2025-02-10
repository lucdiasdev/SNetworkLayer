//
//  Target.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

protocol Target {
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String]? { get }
    var task: Task { get }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public enum ParameterEncoding {
    case httpBody
    case query
}

public enum Task {
    case requestDefault
    case requestWithBodyJSONEncodable(Encodable)
    case requestWithParameters(_ parameters: [String: Any], encodingParameters: ParameterEncoding)
}
