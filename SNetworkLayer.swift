//
//  SNetworkLayer.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation
import UIKit

//MARK: - Extension URL
public extension URL { //MARK: REMOVER E VER UMA FORMA DE APLICAR ISSO EM OUTRO LUGAR PARA INSTANCIAR O SNETWORKLAYER
    init<T: Target>(target: T) {
        if target.path.isEmpty {
            self = target.baseURL
        } else {
            self = target.baseURL.appendingPathComponent(target.path)
        }
    }
}

open class SNetworkLayer<T: Target> {
    
//    var baseURL: URL?
    private let urlSession: URLSession
    private let executor: ExecutorProtocol
    
    public init(executor: ExecutorProtocol = Executor(), urlSession: URLSession = URLSession(configuration: .default)) {
        self.executor = executor
        self.urlSession = urlSession
    }
    
    private func composer(_ target: T,
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
            throw FlowError.decode(NSError(domain: "SNetworkLayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty data"]))
        }
        return try JSONDecoder().decode(D.self, from: data)
    }
    
    public func fetch<V: Codable, E: Codable>(_ target: T,
                                              dataType: V.Type,
                                              errorType: E.Type? = nil,
                                              completion: ((Result<V, FlowError>, _ response: URLResponse?) -> Void)?) -> NetworkDataTask? {
        
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
        
        return NetworkDataTask(task: task)
    }

}
