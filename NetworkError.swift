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
    case apiCustomError(_ error: Codable?)
    
    /// Erro desconhecido — falha geral quando não conseguimos entender a resposta
    case apiError(_ data: Data?)
    
    /// Erro nativo do sistema (ex: sem internet, timeout)
    case network(_ error: NetworkError)
    
    /// Erro de decode ao tentar decodificar sucesso ou erro customizado
    case decode(_ error: Error?)
    
    /// Erro de encode ao tentar passar um Encoder
    case encode(_ error: Error)
    
    /// Erro quando a resposta não pôde ser convertida para HTTPURLResponse
    case invalidResponse
    
    /// Erro quando o Data é vazio
    case noData
    
    /// Erro desconhecido
    case unknown
}

public enum NetworkError: Error {
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

/// protocolo que permite ao consumidor fornecer mensagens customizadas para erros genericos de rede.
/// ao usar um `Error Decodable` seria necessario adotar esse protocolo
/// o projeto pode definir textos amigáveis para exibição ao usuário com base no tipo de erro de rede (ex: `notConnectedNetwork`, `timeOut` e etc)
/// Ex:
/// ```
/// final class CustomErrorMessageProvider: SNetworkLayerErrorNetworkConfigProvider {
///     func message(for error: NetworkError) -> String {
///         switch error {
///         case .notConnectedNetwork:
///             return "Você está offline. Verifique sua conexão com a internet."
///         case .timeOut:
///             return "A conexão está lenta. Tente novamente mais tarde."
///         case .lostConnectedNetwork:
///             return "A conexão com o servidor foi perdida."
///         case .cancelConnectedNetwork:
///             return "A operação foi cancelada."
///         case .unknown:
///             return "Ocorreu um erro desconhecido de rede."
///         }
///     }
/// }
/// ```
/// pode ser configurado uma única vez, idealmente no início do ciclo de vida da aplicação.
/// um exemplo no AppDelegate/SceneDelegate `SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self`
public protocol SNetworkLayerErrorNetworkConfigProvider {
    static var networkErrorMapper: ((NetworkError) -> (any Error & Codable)?)? { get }
    static var decodableErrorMapper: ((DecodingError) -> (any Error & Codable)?)? { get }
}

public struct SNetworkLayerErrorConfiguration {
    public static var provider: (any SNetworkLayerErrorNetworkConfigProvider.Type)?
}
