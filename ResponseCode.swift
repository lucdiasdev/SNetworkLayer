//
//  ResponseCode.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 13/02/25.
//

import Foundation

public enum StatusCode {
    case informationalCode              //0...199 - Informacional - Respostas provisórias ou falha de rede
    case successCode                    //200...299 - Sucesso - Requisições bem-sucedidas
    case successEmptyContentCode        // 204    No Content    Sucesso sem conteúdo
    case redirectionCode                // 300...399    Redirecionamento    Novas localizações para o recurso
    case failureClientCode              // 400...499    Erro do Cliente    Problemas com a requisição do cliente
    case failureServCode                // 500...599    Erro do Servidor    Falhas ao processar a requisição no servidor
    case unknownCode                    // ?
}

public extension URLResponse {
    var validationStatus: StatusCode {
        if let httpResponse = self as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 0...199:
                return .informationalCode
            case 200...299:
                return .successCode
            case 204...204:
                return .successEmptyContentCode
            case 300...399:
                return .redirectionCode
            case 400...499:
                return .failureClientCode
            case 500...599:
                return .failureServCode
            default:
                return .unknownCode
            }
        } else {
            return .unknownCode
        }
    }
}
