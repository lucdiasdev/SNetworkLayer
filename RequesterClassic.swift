//
//  RequesterClassic.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

open class RequesterClassic<T: Target> {
    
    var executor: ExecutorProtocol
    var networkLayer: SNetworkLayer
    
    public init(executor: ExecutorProtocol = Executor(), networkLayer: SNetworkLayer) {
        self.executor = executor
        self.networkLayer = networkLayer
    }
    
    public func fetch<U: Codable, E: Error>(target: T, errorHandler: ErrorHandler<E>? = nil as ErrorHandler<Error>?,
                                            dataType: U.Type, completion: @escaping (Result<U, Error>, URLResponse?) -> Void) {
        
        guard let baseURL = networkLayer.baseURL else {
            assertionFailure("ERROR: baseURL is nil")
            return }
        
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(target.path))
        print(urlRequest.url) //REMOVER
        urlRequest.httpMethod = target.httpMethod.rawValue
        
        if let headers = target.headers {
            headers.forEach { value, key in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        executor.execute(urlRequest: urlRequest) { data, response, error in
            let handler = errorHandler ?? ErrorHandler<E>(customMapping: nil)
            
            if let error = error {
                let mappedError = handler.mapError(from: nil, response: response, error: error)
                completion(.failure(mappedError), response)
                return
            }
            
            guard let data = data else {
                let mappedError = handler.mapError(from: nil, response: response, error: nil)
                completion(.failure(mappedError), response)
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(U.self, from: data)
                completion(.success(decodedData), response)
            } catch {
                let mappedError = handler.mapError(from: data, response: response, error: error)
                completion(.failure(mappedError), response)
            }
        }
    }
}
