//
//  RequesterClassic.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

//open class Requester<T: Target> {
    
//    var executor: ExecutorProtocol
//    var networkLayer: SNetworkLayer
    
//    public init(executor: ExecutorProtocol = Executor(), networkLayer: SNetworkLayer) {
//        self.executor = executor
//        self.networkLayer = networkLayer
//    }
    
//    private func urlRequestConfiguration(target: T) -> URLRequest {
//        guard let baseURL = networkLayer.baseURL else {
//            assertionFailure("ERROR: baseURL is nil")
//            return .init(url: URL(fileURLWithPath: "")) }
//        
//        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(target.path))
//        
//        urlRequest.httpMethod = target.httpMethod.rawValue
//        
//        if let headers = target.headers {
//            headers.forEach { value, key in
//                urlRequest.setValue(value, forHTTPHeaderField: key)
//            }
//        }
//        
//        return urlRequest
//    }
    
//    public func fetch(target: T, completion: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
//        let urlRequest = urlRequestConfiguration(target: target)
//
//        executor.execute(urlRequest: urlRequest) { data, response, error in
//            
//            if let error = error {
//                completion(.failure(error), response)
//                return
//            }
//            
//            guard let data = data else {
//                assertionFailure("ERROR PARSE: data is nil")
//                return
//            }
//            
//            do {
//                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
//                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
//                completion(.success(jsonData), response)
//            } catch {
//                completion(.failure(error), response)
//            }
//        }
//    }
    
//    public func fetch<U: Codable, E: Error>(target: T, errorHandler: ErrorHandler<E>? = nil as ErrorHandler<Error>?,
//                                            dataType: U.Type, completion: @escaping (Result<U, Error>, URLResponse?) -> Void) {
//        let urlRequest = urlRequestConfiguration(target: target)
//        
//        executor.execute(urlRequest: urlRequest) { data, response, error in
//            let handler = errorHandler ?? ErrorHandler<E>(customMapping: nil)
//            
//            if let error = error {
//                let mappedError = handler.mapError(from: nil, response: response, error: error)
//                completion(.failure(mappedError), response)
//                return
//            }
//            
//            guard let data = data else {
//                let mappedError = handler.mapError(from: nil, response: response, error: nil)
//                completion(.failure(mappedError), response)
//                return
//            }
//            
//            do {
//                let decodedData = try JSONDecoder().decode(U.self, from: data)
//                completion(.success(decodedData), response)
//            } catch {
//                let mappedError = handler.mapError(from: data, response: response, error: error)
//                completion(.failure(mappedError), response)
//            }
//        }
//    }
//}
