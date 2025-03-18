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
    var validation: StatusValidation { get }
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

public enum StatusValidation: Equatable {
    
    /// accept any range of status code 200 ... 299 and trigger error if not.
    case accept
    
    /// accept a custom range of status code  and trigger error if not.
    case custom(ClosedRange<Int>)
    
    /// disabled status code validation
    case disabled
    
    public var rangeStatus: ClosedRange<Int> {
        switch self {
        case .accept:
            return 200 ... 299
        case .custom(let customRange):
            return customRange
        case .disabled:
            return ClosedRange(uncheckedBounds: (0,0))
        }
    }
}

public extension Target {
    var baseURL: URL {
        guard let url = URL(string: "http://localhost:3000") else {
            assertionFailure("Invalid static URL string: https://pokeapi.co/api/v2/")
            return URL(fileURLWithPath: "https://pokeapi.co/api/v2/")
        }
        return url
    }
    
    var validation: StatusValidation {
        .disabled
    }
}
