//
//  SNetworkLayer.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

public class SNetworkLayer<T: Target> {
    
    var baseURL: URL?
    private let executor: ExecutorProtocol
    
    public init(executor: ExecutorProtocol = Executor()) {
        self.executor = executor
    }
    
    public func setBaseURL(url: String) {
        guard let url = URL(string: url) else {
            assertionFailure("failure baseURL")
            return
        }
        
        self.baseURL = url
    }
    
    private func urlRequestConfiguration(target: T) -> URLRequest {
        guard let baseURL = self.baseURL else {
            assertionFailure("ERROR: baseURL is nil")
            return .init(url: URL(fileURLWithPath: "")) }
        
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(target.path))
        
        urlRequest.httpMethod = target.httpMethod.rawValue
        
        if let headers = target.headers {
            headers.forEach { value, key in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return urlRequest
    }
    
    public func fetch(target: T, completion: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
        let urlRequest = urlRequestConfiguration(target: target)

        executor.execute(urlRequest: urlRequest) { data, response, error in
            
            if let error = error {
                completion(.failure(error), response)
                return
            }
            
            guard let data = data else {
                assertionFailure("ERROR PARSE: data is nil")
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
                completion(.success(jsonData), response)
            } catch {
                completion(.failure(error), response)
            }
        }
    }
    
}
