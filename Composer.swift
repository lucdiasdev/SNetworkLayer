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
            
        case .requestBodyEncodable(let encodable):
            return try URLRequestBuilder.encodeBody(encodable, into: urlRequest)
            
        case .requestParameters(let parameters, let encodeParameters):
            return try URLRequestBuilder.encodeParameters(parameters, into: urlRequest, as: encodeParameters)
            
        case .requestBodyParameters(let bodyParameters, urlParameters: let urlParameters):
            return try URLRequestBuilder.encodeBodyParameters(body: bodyParameters, url: urlParameters, into: urlRequest)
        }
    }
}

enum URLRequestBuilder {
    static func encodeBody(_ encodable: Encodable, into request: URLRequest) throws -> URLRequest {
        var mutableRequest = request
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(encodable)
            mutableRequest.httpBody = encoded
            return mutableRequest
        } catch {
            throw FlowError.invalidRequest(error)
        }
    }

    static func encodeParameters(_ parameters: [String: Any], into request: URLRequest, as encoding: EncodeParameters) throws -> URLRequest {
        var mutableRequest = request
        do {
            try mutableRequest.encode(parameters: parameters, as: encoding)
            return mutableRequest
        } catch {
            throw FlowError.invalidRequest(error)
        }
    }
    
    static func encodeBodyParameters(body: [String: Any], url: [String: Any], into request: URLRequest) throws -> URLRequest {
        var mutableRequest = request
        
        do {
            try mutableRequest.encode(parameters: url, as: .query)
            
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            mutableRequest.httpBody = data
            mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return mutableRequest
        } catch {
            throw FlowError.invalidRequest(error)
        }
    }
}

private extension URLRequest {
    mutating func encode(parameters: [String: Any], as encoding: EncodeParameters) throws {
        switch encoding {
        case .http:
            let bodyString = parameters
                .map { "\($0.key)=\("\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                .joined(separator: "&")

            setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            httpBody = bodyString.data(using: .utf8)

        case .query:
            guard var urlComponents = URLComponents(string: self.url?.absoluteString ?? "") else {
                throw URLError(.badURL)
            }

            let queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }

            urlComponents.queryItems = queryItems

            guard let updatedURL = urlComponents.url else {
                throw URLError(.badURL)
            }

            self.url = updatedURL
        }
    }
}

extension Encodable {
    func toDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            print("Erro ao converter struct para dicionário: \(error)")
            return nil
        }
    }
}
