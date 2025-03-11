//
//  Executor.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

public protocol ExecutorProtocol {
    //    func execute(urlRequest: URLRequest,
    //                 completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    func execute(urlRequest: URLRequest,
                 session: URLSession,
                 completion: @escaping (Data?, URLResponse?, FlowError?) -> Void) -> URLSessionDataTask
}

public class Executor: ExecutorProtocol {
    
    public init() {}
    
    public func execute(urlRequest: URLRequest, session: URLSession, completion: @escaping (Data?, URLResponse?, FlowError?) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: urlRequest) { data, response, error in
            self.debug(urlRequest, data, response, error)
            if let error = error {
                completion(data, response, FlowError.network(error))
                return
            }
            completion(data, response, nil)
        }
        
        task.resume()
        return task
    }
    
//    public func execute(urlRequest: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
//        let fetch = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//            self.debug(urlRequest, data, response, error)
//            completion(data, response, error)
//        }
//        
//        fetch.resume()
//    }
    
    private func debug(_ request: URLRequest, _ responseData: Data?, _ response: URLResponse?, _ error: Error?) {
        
        print("📲 REQUEST LOG")
        print("🌐 URL: \(request.url?.absoluteString ?? "UNKNOWN")")
        print("▶️ HTTP METHOD: \(request.httpMethod?.uppercased() ?? "UNKNOWN")")
        
//        if let requestHeaders = request.allHTTPHeaderFields,
//            let requestHeadersData = try? JSONSerialization.data(withJSONObject: requestHeaders, options: .prettyPrinted),
//            let requestHeadersString = String(data: requestHeadersData, encoding: .utf8) {
//            print("↗️ HEADERS:\n\(requestHeadersString)")
//        }
        
//        if let requestBodyData = request.httpBody,
//            let requestBody = String(data: requestBodyData, encoding: .utf8) {
//            print("↗️ BODY: \n\(requestBody)")
//        }
        
        if let responseStatusCode = response as? HTTPURLResponse {
            print("\n🚀 RESPONSE LOG")
            switch responseStatusCode.statusCode {
            case 200...299:
                print("🔈 STATUSCODE: \(responseStatusCode.statusCode) ✅")
            case 400...505:
                print("🔈 STATUSCODE: \(responseStatusCode.statusCode) 🆘")
            default:
                print("🔈 STATUSCODE: \(responseStatusCode.statusCode) ✴️")
            }
            
//            if let responseHeadersData = try? JSONSerialization.data(withJSONObject: httpResponse.allHeaderFields, options: .prettyPrinted),
//                let responseHeadersString = String(data: responseHeadersData, encoding: .utf8) {
//                print("↙️ HEADERS:\n\(responseHeadersString)")
//            }
            
            if let responseData = responseData,
               let responseBodyData =  String(data: responseData, encoding: .utf8), !responseData.isEmpty {
                print("🙋🏻 BODY LOG:\n\(responseBodyData)\n")
            }
        }
        
//        if let urlError = error as? URLError {
//            print("\n❌ ======= ERROR =======")
//            print("\n❌ CODE: \(urlError.errorCode)")
//            print("\n❌ DESCRIPTION: \(urlError.localizedDescription)\n")
//        }
        
//        print("======== END OF: \(uuid) ========\n\n")
    }
}
