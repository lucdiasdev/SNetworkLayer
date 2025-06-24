//
//  FlowError+Extension.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 23/05/25.
//

import Foundation

/// tenta extrair e converter o erro `apiCustomError` para um tipo específico definido pelo projeto consumidor.
///
/// essa função é útil quando o consumidor do framework define um modelo customizado de erro (por exemplo, `MyBackendError`)
/// e precisa acessá-lo de forma segura após uma falha retornada como `FlowError`.
///
/// - Parameter type: O tipo esperado do erro customizado definido pelo consumidor.
/// - Returns: Uma instância do tipo esperado, caso o `FlowError` contenha um erro do tipo `apiCustomError` e o cast seja possível; caso contrário, retorna `nil`.
public extension FlowError {
    func `as`<T: Error>(_ type: T.Type) -> T? {
        if case let .apiCustomError(error) = self {
            return error as? T
        }
        return nil
    }
}
