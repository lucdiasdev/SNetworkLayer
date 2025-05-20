//
//  Target.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

public protocol Target {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headerParamaters: [String: String]? { get }
    var task: Task { get }
}

public enum HTTPMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum EncodeParameters {
    case http
    case query
}

public enum Task {
    /// monta uma requisição simples sem dados adicionais.
    case requestDefault
    
    /// monta uma requisição com um ​​corpo `body` de solicitação definido com o tipo `Encodable`
    case requestBodyEncodable(Encodable)
    
    /// monta uma requisição com parametros de URL como `query string`
    /// definindo o `EncodeParameters` como `.query`
    /// e tambem defini uma requisição como `x-www-form-urlencoded` definindo o `EncodeParameters` como `.http`
    case requestParameters(parameters: [String: Any], encodeParameters: EncodeParameters)
    
    /// monta uma requisição com um corpo `body` de solicitação definido com o tipo `Encodable`
    /// e tamabem permite passar parâmetros de URL como `query string` ao mesmo tempo
    case requestBodyEncodableWithParameters(Encodable, queryParameters: [String: Any])
    
    /// monta uma requisição com um conjunto de corpos do tipo dicionário
    /// permite passar parâmetros como corpo `body` da requisição
    /// e tambem parâmetros de URL como `query string` ao mesmo tempo
    case requestBodyAndQueryParameters(bodyParameters: [String: Any], queryParameters: [String: Any]?)
}
