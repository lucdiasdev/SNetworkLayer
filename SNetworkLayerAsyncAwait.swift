//
//  SNetworkLayerAsyncAwait.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 30/07/25.
//

import Foundation

public extension SNetworkLayer {
    
    private func composer(_ target: T,
                          _ urlSession: URLSession) async throws -> (URLRequest, Data?, URLResponse?) {
        let request = try ComposerTarget.composeRequest(target)
        let (data, response) = try await self.executor.execute(urlRequest: request, session: urlSession)
        return (request, data, response)
    }
    
    @discardableResult
    private func superFetch<V: Codable, E: Error & Codable>(_ target: T,
                                                            dataType: V.Type,
                                                            errorType: E.Type) async throws -> V {
        do {
            let (_, data, response) = try await self.composer(target, self.urlSession)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FlowError.invalidResponse
            }
            
            let statusCode = httpResponse.statusCode
            
            /// sucesso (status 2xx)
            if (200...299).contains(statusCode) {
                if let data = data {
                    do {
                        return try decode(data, to: V.self)
                    } catch {
                        if let decodingError = error as? DecodingError,
                           let mapper = SNetworkLayerErrorConfiguration.provider?.decodableErrorMapper,
                           let mapped = mapper(decodingError) as? E {
                            throw FlowError.apiCustomError(mapped)
                        } else {
                            throw FlowError.decode(error)
                        }
                    }
                } else {
                    throw FlowError.noData
                }
                /// fallback de error
                /// tentativa de decodificar erro customizado
            } else {
                if let error = data {
                    do {
                        let decodedError = try decode(error, to: E.self)
                        throw FlowError.apiCustomError(decodedError)
                    } catch {
                        throw FlowError.decode(error)
                    }
                } else {
                    throw FlowError.noData
                }
            }
        } catch {
            if case let .network(networkError) = error as? FlowError {
                if let mapper = SNetworkLayerErrorConfiguration.provider?.networkErrorMapper, let mapped = mapper(networkError) as? E {
                    throw FlowError.apiCustomError(mapped)
                } else {
                    throw FlowError.network(networkError)
                }
            } else {
                throw FlowError.unknown
            }
        }
    }
    
    @discardableResult
    func fetch<V: Codable, E: Error & Codable>(_ target: T,
                                                      dataType: V.Type,
                                                      errorType: E.Type) async throws -> V {
        do {
            return try await superFetch(target, dataType: dataType, errorType: errorType)
        } catch {
            if let errorType = error as? FlowError, let throwError = errorType.as(E.self) {
                throw throwError
            } else {
                print("🚨 native error:\n\(error) \nconfigure SNetworkLayerConfigProvider to receive native error in cast for your errorType")
                throw error
            }
        }
    }
}
