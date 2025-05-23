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

//TODO: CORRIGIR ISSO AQUI DE ALGUMA FORMA
/// protocolo que permite ao consumidor fornecer mensagens customizadas para erros genericos de rede.
/// ao adotar esse protocolo, o projeto pode definir textos amigáveis para exibição ao usuário om base no tipo de erro de rede (ex: `notConnectedNetwork`, `timeOut` e etc)
/// Ex:
/// ```
/// final class CustomErrorMessageProvider: NetworkErrorMessageProvider {
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
public protocol NetworkErrorMessageProvider {
    func message(for error: NetworkError) -> String
}

/// enum que funciona como um ponto de configuração central do SNetworkLayer (`SNetworkLayerConfigProvider`)
/// se preferir, pode ser configurado uma única vez, idealmente no início do ciclo de vida da aplicação.
/// O `messageProvider` é uma referência injetável para um objeto que adota `NetworkErrorMessageProvider`,
/// permitindo que o framework acesse mensagens customizadas sem acoplamento com o projeto do consumidor.
public enum SNetworkLayerConfigProvider {
    public static var messageProvider: NetworkErrorMessageProvider?
}

/// extensão que adiciona uma propriedade computada à enum `FlowError`,
/// permitindo acessar uma mensagem amigável associada a erros do tipo `.network`,
/// caso o projeto tenha fornecido um `messageProvider` via `SNetworkLayerConfig`.
public extension FlowError {
    var userMessage: String? {
        switch self {
        case .network(let error):
            /// retorna a mensagem customizada definida pelo projeto para o tipo de NetworkError específico.
            /// no caso do exemplo acima foi configurado no `CustomErrorMessageProvider`
            return SNetworkLayerConfigProvider.messageProvider?.message(for: error)
        default:
            return nil
        }
    }
}
