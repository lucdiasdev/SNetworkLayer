//
//  APIExample.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 19/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import SNetworkLayer

enum APIExample {
    case endpointExample
}

extension APIExample: Target {
    var baseURL: URL {
        guard let url = URL(string: "http://localhost:3000/") else {
            assertionFailure("Invalid static URL string: http://localhost:3000/")
            return URL(fileURLWithPath: "http://localhost:3000/")
        }
        return url
    }
    
    var headerParamaters: [String : String]? {
        return nil
    }
    
    var path: String {
        switch self {
        case .endpointExample:
            return "endpoint/example"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .endpointExample:
            return .get
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .endpointExample:
            return nil
        }
    }
    
    var task: Task {
        switch self {
        case .endpointExample:
            return .requestDefault
        }
    }
}
