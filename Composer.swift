//
//  Composer.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 11/03/25.
//

import UIKit

enum ComposerTarget {
    static func requestCreate<T: Target>(_ target: T) throws -> URLRequest {
        var urlRequest = URLRequest(url: URL(target: target))
        urlRequest.allHTTPHeaderFields = target.headerParamaters
        urlRequest.httpMethod = target.httpMethod.rawValue
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        switch target.task {
        case .requestDefault:
            return urlRequest
        case .bodyParametersEncodable(let encodable):
            break
        case .bodyParameters(_, let encodingParameters):
            break
        }
        
        return urlRequest
    }
}
