//
//  Executor.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

protocol ExecutorProtocol {
    func execute(urlRequest: URLRequest,
                 completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

final class Executor: ExecutorProtocol {
//    var loggerType: LoggerType = .json
    
    func execute(urlRequest: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let fetch = URLSession.shared.dataTask(with: urlRequest, completionHandler: completion)
//        LoggerData().loggerResponse()
        fetch.resume()
    }
}
