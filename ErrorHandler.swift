//
//  ErrorHandler.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

// Enum para erros padrão do sistema
enum DefaultNetworkError: Error {
    case serverError(Error)
    case unknownError
    case parsingError(Error)
    
    var description: String {
        switch self {
        case .serverError(let error):
            return error.localizedDescription
        case .unknownError:
            return "Ocorreu um erro desconhecido."
        case .parsingError:
            return "Erro ao tentar decodificar a resposta."
        }
    }
}

protocol ErrorMappingProtocol {
//    associatedtype CustomError: Error
    func mapError(from data: Data?, response: URLResponse?, error: Error?) -> Error
}

public class ErrorHandler<E: Error>: Error, ErrorMappingProtocol {
    
    private let customMapping: ((Data?, URLResponse?) -> E?)?
    
    init(customMapping: ((Data?, URLResponse?) -> E)? = nil) {
        self.customMapping = customMapping
    }
    
    func mapError(from data: Data?, response: URLResponse?, error: Error?) -> Error {
        if let customError = customMapping?(data, response) {
            return customError
        }
        
        if let defaultError = error as? E {
            return defaultError
        }
        
        return DefaultNetworkError.unknownError.localizedDescription as! E
    }
}
