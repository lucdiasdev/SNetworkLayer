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
        
//        switch target.task {
//        case .requestPlain:
//            return request
//        case .requestData(let data):
//            request.httpBody = data
//        case .requestJSONEncodable(let body):
//            return try request.encoded(encodable: body)
//        case .requestCompositeParameters(let bodyParameters, let urlParameters):
//            return try request.encoded(bodyParameters: bodyParameters, urlParameters: urlParameters)
//        case .requestParameters(let parameters, let encode):
//            return try request.encoded(parameters: parameters, paramEncode: encode)
//        case .uploadMultipart(let files):
//            return try request.multipart(files)
//        }
        
        return urlRequest
    }
}
