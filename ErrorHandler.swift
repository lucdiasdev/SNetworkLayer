//
//  ErrorHandler.swift
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
    case apiError(_ error: Any, statusCode: Int)
    
    /// Erro nativo do sistema (ex: sem internet, timeout)
    case network(_ error: Error)
    
    /// Erro de decode ao tentar decodificar sucesso ou erro customizado
    case decode(_ error: Error)
    
    /// Erro desconhecido — falha geral quando não conseguimos entender a resposta
    case unhandled(_ data: Data?, statusCode: Int?)
    
    /// Erro quando a resposta não pôde ser convertida para HTTPURLResponse
    case invalidResponse
}
