//
//  APIStruct.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 19/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import SNetworkLayer

enum APIStruct {
    case testUrl
}

extension APIStruct: Target {    
    var headerParamaters: [String : String]? {
        return nil
    }
    
    var path: String {
        switch self {
        case .testUrl:
            return "endpoint/test"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .testUrl:
            return .get
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .testUrl:
            return nil
        }
    }
    
    var task: Task {
        switch self {
        case .testUrl:
            return .requestDefault
        }
    }
}
