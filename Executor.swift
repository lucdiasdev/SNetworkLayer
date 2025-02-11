//
//  Executor.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

public protocol ExecutorProtocol {
    func execute(urlRequest: URLRequest,
                 completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

public class Executor: ExecutorProtocol {
    public init() { }
    public func execute(urlRequest: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let fetch = URLSession.shared.dataTask(with: urlRequest, completionHandler: completion)
        fetch.resume()
    }
}
