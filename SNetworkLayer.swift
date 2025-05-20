//
//  SNetworkLayer.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation
import UIKit

open class SNetworkLayer<T: Target> {
    
    private let urlSession: URLSession
    private let executor: ExecutorProtocol
    
    public init(executor: ExecutorProtocol = Executor(), urlSessionConfiguration: URLSessionConfiguration) {
        self.executor = executor
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }
    
    /// inicializador que encapsula uma configuração para urlSession
    /// caso queira personalizar alguma dessas configurações, basta sobrescrever os parametros desejados
    /// suponha que voce tenha sua classe de service conforme construção utilizando o SNetworkLayer:
    /// - ex.: `Class ExampleService: SNetworkLayer<ExampleAPI>`
    /// ao inicializar a instancia do seu service você utiliza `let service = ExampleService(requestTimeOut: .long, resourceTimeOut: .short)` ou alguma propriedade a sua escolha
    public convenience init(requestTimeOut: TimeIntervalRequestType = .short, resourceTimeOut: TimeIntervalRequestType = .long,
                            urlCache: URLCache? = nil, urlCredentialStorage: URLCredentialStorage? = nil,
                            httpCookieAcceptPolicy: HTTPCookie.AcceptPolicy = .always,
                            cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
                            waitsForConnectivity: Bool = true) {
        
        let config = URLSessionConfiguration.default
        
        /// `requestTimeout` timeout para inatividade de uma requisição
        config.timeoutIntervalForRequest = requestTimeOut.rawValue
        /// `resourceTimeout` timeout total para baixar todo o recurso
        config.timeoutIntervalForResource = resourceTimeOut.rawValue
        /// `urlCache` Desabilita o cache da URLSession
        config.urlCache = urlCache
        /// `urlCredentialStorage` Desativa o armazenamento automático de credenciais (como login/senha)
        config.urlCredentialStorage = urlCredentialStorage
        /// `httpCookieAcceptPolicy` Define que a sessão deve sempre aceitar cookies de qualquer origem.``
        config.httpCookieAcceptPolicy = httpCookieAcceptPolicy
        /// `requestCachePolicy` Garante que a sessão ignora qualquer cache local ou remoto ao fazer requisições.``
        config.requestCachePolicy = cachePolicy
        /// `waitsForConnectivity` URLSession espera que a conectividade volte antes de iniciar a requisição (true)
        /// a requisição falha imediatamente com erro do tipo .notConnectedToInternet (false)
        config.waitsForConnectivity = waitsForConnectivity

        self.init(urlSessionConfiguration: config)
    }
    
    private func composer(_ target: T,
                         _ urlSession: URLSession,
                         completion: @escaping (_ data: Data?, _ request: URLRequest?, _ response: URLResponse?, _ error: FlowError?) -> Void) -> NetworkDataTask? {
        do {
            /// `Composer` retorna um `URLSession` a partir do `Target`
            /// cria a url a ser utilizada com seus devidos parametros
            /// promovento o encapsulamento de headers, method http e body
            let request = try ComposerTarget.composeRequest(target)
            
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
            throw FlowError.decode(NSError(domain: "SNetworkLayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty data"]))
        }
        return try JSONDecoder().decode(D.self, from: data)
    }
    
    //MARK: - WITH CODABLE AND ERROR TYPE
//    public func fetch<V: Codable, E: Codable>(_ target: T,
//                                              dataType: V.Type,
//                                              errorType: E.Type? = nil,
//                                              completion: ((Result<V, FlowError>, _ response: URLResponse?) -> Void)?) -> NetworkDataTask? {
//        
//        let task = self.composer(target, self.urlSession) { [weak self] data, request, response, error in
//            guard let self = self else { return }
//            
//            // 🛑 Erro nativo (ex: sem internet, timeout, etc)
//            if let error = error {
//                completion?(.failure(.network(error)), response)
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion?(.failure(.invalidResponse), response)
//                return
//            }
//            
//            let statusCode = httpResponse.statusCode
//            
//            // ✅ Status code 2xx = sucesso
//            if (200...299).contains(statusCode) {
//                do {
//                    let decoded = try self.decode(data, to: V.self)
//                    completion?(.success(decoded), response)
//                } catch {
//                    debugPrint("🪵 Falha ao decodificar sucesso:", error)
//                    completion?(.failure(.decode(error)), response)
//                }
//                return
//            }
//            
//            // ❌ Status code de erro (ex: 400+) — tenta decodificar erro customizado
//            if let data = data, let errorType = errorType {
//                do {
//                    let decodedError = try self.decode(data, to: E.self)
//                    completion?(.failure(.apiError(decodedError, statusCode: statusCode)), response)
//                    return
//                } catch {
//                    debugPrint("🪵 Falha ao decodificar erro customizado:", error)
//                }
//            }
//            
//            // ⚠️ Não conseguimos decodificar o erro — fallback para erro genérico
//            completion?(.failure(.unhandled(data, statusCode: statusCode)), response)
//        }
//        
//        return NetworkDataTask(task: task)
//    }
    
    //MARK: - WITH DATA AND ERROR TYPE
//    public func fetch<E: Codable>(_ target: T,
//                                  errorType: E.Type? = nil,
//                                  completion: ((Result<Data, FlowError>, _ response: URLResponse?) -> Void)?) -> NetworkDataTask? {
//        
//        let task = self.composer(target, self.urlSession) { [weak self] data, request, response, error in
//            guard let self = self else { return }
//            
//            // 🛑 Erro nativo (sem internet, timeout etc)
//            if let error = error {
//                if case let FlowError.network(networkError) = error {
//                    completion?(.failure(.network(networkError)), response)
//                } else {
//                    completion?(.failure(.network(.unknown)), response)
//                }
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                completion?(.failure(.invalidResponse), response)
//                return
//            }
//            
//            let statusCode = httpResponse.statusCode
//            
//            // ✅ Sucesso (status 2xx)
//            if (200...299).contains(statusCode) {
//                if let data = data {
//                    completion?(.success(data), response)
//                } else {
//                    completion?(.failure(.invalidResponse), response)
//                }
//                return
//            }
//            
//            // ❌ Tentativa de decodificar erro customizado
//            if let data = data, let errorType = errorType {
//                do {
//                    let decodedError = try self.decode(data, to: E.self)
//                    completion?(.failure(.apiCustomError(decodedError)), response)
//                    return
//                } catch {
//                    completion?(.failure(.noData), response)
//                }
//            }
//        }
//        
//        return task
//    }
    
    //MARK: - WITH DATA AND ERROR DEFAULT
    @discardableResult
    public func fetch(_ target: T,
                      completion: ((Result<Data, FlowError>, _ response: URLResponse?) -> Void)?) -> NetworkDataTask? {
        
        let task = self.composer(target, self.urlSession) { [weak self] data, request, response, error in
            guard let _ = self else { return }
            
            /// erro nativo `NetworkError` (sem internet, timeout e etc)
            if let error = error {
                if case let FlowError.network(networkError) = error {
                    completion?(.failure(.network(networkError)), response)
                } else {
                    completion?(.failure(.network(.unknown)), response)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(.failure(.invalidResponse), response)
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            /// sucesso (status 2xx)
            if (200...299).contains(statusCode) {
                if let data = data {
                    completion?(.success(data), response)
                } else {
                    completion?(.failure(.noData), response)
                }
                return
            }
            
            /// fallback de error (nao existe um `custom error` neste fetch)
            if let data = data {
                completion?(.failure(.apiError(data)), response)
            } else {
                completion?(.failure(.noData), response)
            }
            
        }
        
        return task
    }

}
