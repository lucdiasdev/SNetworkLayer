//
//  SNetworkLayer.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation
import UIKit

//MARK: - URLSessionTask
public class SessionFetcher {
    internal var sessionTask: URLSessionTask?
    
    public func cancel() {
        guard let sessionTask = sessionTask else { return }
        switch sessionTask.state {
        case .running, .suspended, .canceling:
            sessionTask.cancel()
        case .completed:
            break
        @unknown default:
            break
        }
    }
}

//MARK: - Extension URL
public extension URL {
    init<T: Target>(target: T) {
        if target.path.isEmpty {
            self = target.baseURL
        } else {
            self = target.baseURL.appendingPathComponent(target.path)
        }
    }
}

//MARK: - Fetcher
open class SNetworkLayer<T: Target> {
    
//    var baseURL: URL?
    private let urlSession: URLSession
    private let executor: ExecutorProtocol
    
    public init(executor: ExecutorProtocol = Executor(), urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.executor = executor
        self.urlSession = urlSession
    }
    
    public func composer(_ target: T,
                         _ urlSession: URLSession,
                         completion: @escaping (_ data: Data?, _ request: URLRequest?, _ response: URLResponse?, _ error: FlowError?) -> Void) -> URLSessionDataTask? {
        do {
            let request = try ComposerTarget.requestCreate(target)
            return self.executor.execute(urlRequest: request, session: urlSession) { data, response, error in
                completion(data, request, response, error)
            }
        } catch {
            completion(nil, nil, nil, FlowError.invalidRequest(error))
            return nil
        }
    }
    
    private func decode<D: Decodable>(_ data: Data?, to type: D.Type) throws -> D {
        guard let data = data else {
            throw FlowError.decode(NSError(domain: "SNetworkLayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dados vazios"]))
        }
        return try JSONDecoder().decode(D.self, from: data)
    }
    
    public func fetch<V: Codable, E: Codable>(_ target: T,
                                              dataType: V.Type,
                                              errorType: E.Type? = nil,
                                              completion: ((Result<V, FlowError>, _ response: URLResponse?) -> Void)?) -> URLSessionTask? {
        
        let task = self.composer(target, self.urlSession) { [weak self] data, request, response, error in
            guard let self = self else { return }
            
            // 🛑 Erro nativo (ex: sem internet, timeout, etc)
            if let error = error {
                completion?(.failure(.network(error)), response)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(.failure(.invalidResponse), response)
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            // ✅ Status code 2xx = sucesso
            if (200...299).contains(statusCode) {
                do {
                    let decoded = try self.decode(data, to: V.self)
                    completion?(.success(decoded), response)
                } catch {
                    debugPrint("🪵 Falha ao decodificar sucesso:", error)
                    completion?(.failure(.decode(error)), response)
                }
                return
            }
            
            // ❌ Status code de erro (ex: 400+) — tenta decodificar erro customizado
            if let data = data, let errorType = errorType {
                do {
                    let decodedError = try self.decode(data, to: E.self)
                    completion?(.failure(.apiError(decodedError, statusCode: statusCode)), response)
                    return
                } catch {
                    debugPrint("🪵 Falha ao decodificar erro customizado:", error)
                }
            }
            
            // ⚠️ Não conseguimos decodificar o erro — fallback para erro genérico
            completion?(.failure(.unhandled(data, statusCode: statusCode)), response)
        }
        
        return task
    }
    

    
//    @discardableResult
//    public func fetch(_ target: T, completion: ((Result<Data?, NetworkError>, _ response: URLResponse?) -> Void)?) -> SessionFetcher {
//        
//        let fetcherTask = SessionFetcher()
//        
//        let task = self.composer(target, urlSession) { [weak self] data, request, response, error in
//            guard let self = self else { return }
//            
//            let responseTime = Date().timeIntervalSince(Date())
//            
//            func handleFailure(_ apiError: NetworkError) {
//                guard let request = request, let resp = response else {
//                    completion?(.failure(apiError), response)
//                    return
//                }
//
//                self.handleRequestError(request, response: resp, error: apiError) { (result) in
//                    switch result {
//                    case .none:
//                        completion?(.failure(apiError), response)
//                    case .retry(let request):
//                        fetcherTask.sessionTask = self.retryRequest(target, request, completion: completion)
//                    }
//                }
//            }
//            
//            if let error = error, let errorNetwork = error.underlying {
//                let fetcherError = NetworkError.network(errorNetwork)
//                completion?(.failure(fetcherError), response)
//            } else if target.validation != .disabled  {
//                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
//                    handleFailure(self.checkAPIError(data) ?? NetworkError.unknown)
//                    return
//                }
//                
//                if target.validation.rangeStatus.contains(statusCode) {
//                    completion?(.success(data), response)
//                    return
//                }
//                
//                let errorObject = ValidationError(self.checkAPIError(data), statusCode: statusCode)
//                handleFailure(.api(errorObject))
//            } else {
//                guard let apiError = self.checkAPIError(data) else {
//                    completion?(.success(data), response)
//                    return
//                }
//                handleFailure(apiError)
//            }
//            return
//        }
//        
//        fetcherTask.sessionTask = task
//        return fetcherTask
//    }
    
//    @discardableResult
//    public func fetch<V: Codable>(_ target: T, dataType: V.Type, completion: ((Result<V, NetworkError>, _ response: URLResponse?) -> Void)?) -> SessionFetcher? {
//        let dataTask = self.fetch(target) {[weak self] (result, response) in
//            guard let self = self else { return }
//            switch result {
//            case .success(let responseData):
//                do {
//                    if let object = try self.decoding(responseData, type: dataType) {
//                        completion?(.success(object), response)
//                        return
//                    }
//                    completion?(.failure(.parse(nil)), response)
//                    return
//                } catch {
//                    completion?(.failure(.parse(error)), response)
//                }
//            case .failure(let error):
//                completion?(.failure(error), response)
//            }
//        }
//        return dataTask
//    }
    
//    func decoding<P: Codable>(_ data: Data?, type: P.Type) throws -> P? {
//        guard let data = data else { return nil }
//        let decoder = JSONDecoder()
//        let object = try decoder.decode(type.self, from: data)
//        return object
//    }
    
//    public func checkAPIError(_ data: Data?) -> NetworkError? {
//        do {
//            if let responseData = data,
//                let apiResponse = try self.decoding(responseData, type: APIErrorResponse.self),
//                let apiError = apiResponse.error {
//                return .api(apiError)
//            }
//            return nil
//        } catch {
//            return nil
//        }
//    }
    
//    public enum RequestErrorHandleResult {
//        case none
//        case retry(URLRequest)
//    }
//    
//    open func handleRequestError(_ request: URLRequest,
//                                 response: URLResponse,
//                                 error: NetworkError,
//                                 completion: @escaping ((RequestErrorHandleResult) -> Void)) {
//        completion(.none)
//    }
    
//
//    fileprivate func retryRequest(_ target: T,
//                                  _ request: URLRequest,
//                                  completion: ((Result<Data?, NetworkError>,
//                                                _ response: URLResponse?) -> Void)?) -> URLSessionTask? {
//        let startRequestTime = Date()
//        return self.composer(target, self.urlSession) { [weak self] (data, request, response, error) in
//            guard let self = self else { return }
//            let responseTime = Date().timeIntervalSince(startRequestTime)
//            guard let e = error, let networkError = e.underlyingError else {
//                completion?(.success(data), response)
//                return
//            }
//            let fetcherError = NetworkError.network(networkError)
//            completion?(.failure(fetcherError), response)
//        }
//    }
}
