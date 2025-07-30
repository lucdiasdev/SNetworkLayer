//
//  Executor.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

public protocol ExecutorProtocol {
    func execute(urlRequest: URLRequest, session: URLSession, completion: @escaping (Data?, URLResponse?, FlowError?) -> Void) -> NetworkDataTask
    func execute(urlRequest: URLRequest, session: URLSession) async throws -> (Data?, URLResponse?)
}

public class Executor: ExecutorProtocol {
    
    public init() {}
    
    public func execute(urlRequest: URLRequest, session: URLSession, completion: @escaping (Data?, URLResponse?, FlowError?) -> Void) -> NetworkDataTask {
        let startTime = Date()
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            self.log(urlRequest, data, response, error, duration: duration)
            
            if let error = error as NSError? {
                /// converte erro de rede nativo (`NSError`) para um modelo de erro customizado (`FlowError`)
                let resolved = error.resolveNetworkError()
                completion(data, response, FlowError.network(resolved))
                return
            }
            
            completion(data, response, nil)
        }
        
        let networkDataTask = NetworkDataTask(task: task)
        networkDataTask.resume()
        return networkDataTask
    }
    
    public func execute(urlRequest: URLRequest, session: URLSession) async throws -> (Data?, URLResponse?) {
        let startTime = Date()
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            self.log(urlRequest, data, response, nil, duration: duration)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FlowError.invalidResponse
            }
            
            return (data, httpResponse)
        } catch {
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            self.log(urlRequest, nil, nil, error, duration: duration)
            
            if let error = error as NSError? {
                let resolved = error.resolveNetworkError()
                throw FlowError.network(resolved)
            }
            
            throw FlowError.unknown
        }
    }
    
    private func log(_ request: URLRequest, _ responseData: Data?, _ response: URLResponse?, _ error: Error?, duration: TimeInterval) {
        
        print("📲 REQUEST LOG")
        print("🌐 URL: \(request.url?.absoluteString ?? "UNKNOWN")")
        print("▶️ HTTP METHOD: \(request.httpMethod?.uppercased() ?? "UNKNOWN")")
        print("⏱️ TIME INTERVAL: \(String(format: "%.3f", duration))s")
        
        if let requestHeaders = request.allHTTPHeaderFields,
            let requestHeadersData = try? JSONSerialization.data(withJSONObject: requestHeaders, options: .prettyPrinted),
            let requestHeadersString = String(data: requestHeadersData, encoding: .utf8) {
            if requestHeaders.isEmpty {
                print("🧖🏻 HEADERS IS EMPTY")
            } else {
                print("💆🏻 HEADERS:\n\(requestHeadersString)")
            }
        }
        
        if let requestBodyData = request.httpBody,
            let requestBody = String(data: requestBodyData, encoding: .utf8),
            !requestBody.isEmpty {
                print("🙆🏻 BODY: \n\(requestBody)")
            }
        
        if let response = response as? HTTPURLResponse {
            print("\n🚀 RESPONSE LOG")
            switch response.statusCode {
            case 200...299: print("🔈 STATUSCODE: \(response.statusCode) 🟢")
            case 400...505: print("🔈 STATUSCODE: \(response.statusCode) 🔴")
            default: print("🔈 STATUSCODE: \(response.statusCode) 🟠")
            }
            
            if let responseHeadersData = try? JSONSerialization.data(withJSONObject: response.allHeaderFields, options: .prettyPrinted),
                let responseHeadersString = String(data: responseHeadersData, encoding: .utf8) {
                if responseHeadersData.isEmpty {
                    print("🧖🏻 HEADERS IS EMPTY")
                } else {
                    print("💆🏻 HEADERS:\n\(responseHeadersString)")
                }

            }
            
            if let responseData = responseData,
               let responseBodyData =  String(data: responseData, encoding: .utf8), !responseData.isEmpty {
                print("🙆🏻 BODY LOG:\n\(responseBodyData)\n")
            }
        }
    }
}
