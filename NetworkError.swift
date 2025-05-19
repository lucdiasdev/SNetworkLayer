//
//  NetworkError.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

//MARK: FlowError
public enum FlowError: Error {
    /// Erro para URLs invalidas
    case invalidRequest(_ error: Error)
    
    /// Erro vindo do backend, mapeado com o modelo de erro customizado do desenvolvedor
    case apiCustomError(_ error: Any)
    
    /// Erro desconhecido — falha geral quando não conseguimos entender a resposta
    case apiError(_ data: Data?)
    
    /// Erro nativo do sistema (ex: sem internet, timeout)
    case network(_ error: NetworkError)
    
    /// Erro de decode ao tentar decodificar sucesso ou erro customizado
    case decode(_ error: Error)
    
    /// Erro de encode ao tentar passar um dict para Encoder
    case encode(_ error: Error)
    
    /// Erro quando a resposta não pôde ser convertida para HTTPURLResponse
    case invalidResponse
    
    /// Erro quando o Data é vazio
    case noData
}

public enum NetworkError: Error, LocalizedError {
    /// Erro desconhecido
    case unknown
    
    /// Requisição atingiu o tempo limite de conexão `NetworkTimeInterval`
    case timeOut
    
    /// Sem conexão com a Internet
    case notConnectedNetwork
    
    /// Conexão com o servidor foi perdida
    case lostConnectedNetwork
    
    /// Operação assíncrona foi cancelada
    case cancelConnectedNetwork
}

/// abstração para mapear erros de rede nativos (`NSError`) em erros de domínio customizados (`NetworkError`)
/// essa função cobre casos comuns e retorna `.unknown` quando o erro não se encaixa em nenhum dos casos tratados.
extension Error {
    func resolveNetworkError() -> NetworkError {
        let nsError = self as NSError
        switch (nsError.domain, nsError.code) {
        case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet):
            return .notConnectedNetwork
        case (NSURLErrorDomain, NSURLErrorTimedOut):
            return .timeOut
        case (NSURLErrorDomain, NSURLErrorNetworkConnectionLost):
            return .lostConnectedNetwork
        case (NSURLErrorDomain, NSURLErrorCancelled):
            return .cancelConnectedNetwork
        default:
            return .unknown
        }
    }
}

//TODO: tentar adicionar alem das mensagem dos erros nativos tentar adicionar o erro customizado de backend (CustomNetworkError da AppDelegate)
public protocol NetworkErrorMessageProvider {
    func message(for error: NetworkError) -> String
}

public enum SNetworkLayerConfig {
    public static var messageProvider: NetworkErrorMessageProvider?
}

public extension FlowError {
    var userMessage: String? {
        switch self {
        case .network(let error):
            return SNetworkLayerConfig.messageProvider?.message(for: error)
        default:
            return nil
        }
    }
}
