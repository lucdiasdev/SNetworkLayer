//
//  Composer.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 11/03/25.
//

import UIKit

extension URL {
    init<T: Target>(target: T) {
        if target.path.isEmpty {
            self = target.baseURL
        } else {
            self = target.baseURL.appendingPathComponent(target.path)
        }
    }
}

enum ComposerTarget {
    //TODO: ALTERAR ESSA NOMENCLATURA
    static func requestCreate<T: Target>(_ target: T) throws -> URLRequest {
        var urlRequest = URLRequest(url: URL(target: target))
        urlRequest.allHTTPHeaderFields = target.headerParamaters
        urlRequest.httpMethod = target.httpMethod.rawValue
        
        /// Define o header padrão `Content-Type` como `application/json` caso ele não tenha sido definido pelo Target
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        switch target.task {
        case .requestDefault:
            return urlRequest
            /// retorna a requisição padrão, sem corpo
        case .requestBodyEncodable(let encodable):
            return try URLRequestBuilder.encodeBody(encodable, into: urlRequest)
            /// codifica um objeto (modelo) `Encodable` em JSON e o insere como corpo da requisição
            /// `URLRequestBuilder.encodeBody` retorna a URLRequest com o corpo codificado via JSONEncoder
        case .requestParameters(let parameters, let encodeParameters):
            return try URLRequestBuilder.encodeParameters(parameters, into: urlRequest, as: encodeParameters)
            /// codifica os parametros fornecidos conforme o tipo de encoding definido
            /// `.query` `.http`
            /// `URLRequestBuilder.encodeParameters` retorna a URLRequest com parametros em base no tipo de codificação (encoding) citado acima
        case .requestBodyEncodableWithParameters(let encodable, let parameters):
            var requestBodyEncodableWithQueryParams = try URLRequestBuilder.encodeParameters(parameters, into: urlRequest, as: .query)
            requestBodyEncodableWithQueryParams = try URLRequestBuilder.encodeBody(encodable, into: requestBodyEncodableWithQueryParams)
            return requestBodyEncodableWithQueryParams
            /// codifica os parametros fornecidos conforme o tipo de encoding definido
            /// utiliza o `URLRequestBuilder.encodeParameters` que retorna a URLRequest com parametros (parameters)
            /// codifica um objeto (modelo) `Encodable` em JSON e o insere como corpo da requisição
            /// utiliza o `URLRequestBuilder.encodeBody` que retorna a URLRequest com o corpo codificado via JSONEncoder
            /// utilizando-se para construir um corpo da requisição juntamente com parametros na forma de query
        case .requestBodyAndQueryParameters(let bodyParameters, let queryParameters):
            return try URLRequestBuilder.encodeBodyAndParameters(bodyParameters, queryParameters, into: urlRequest)
            /// serializa o dicionário recebido em `bodyParameters` em JSON e define como corpo (`body`) da requisição
            /// utiliza o `URLRequestBuilder.encodeBodyAndParameters` que retorna a URLRequest montada com o corpo
            /// se existir conteudo no `queryParameters` (ele é um dicionário opcional) adiciona a URL parametros como query string
        }
    }
}

enum URLRequestBuilder {
    static func encodeBody(_ encodable: Encodable, into request: URLRequest) throws -> URLRequest {
        var mutableRequest = request
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(encodable)
            mutableRequest.httpBody = encoded
            return mutableRequest
        } catch {
            throw FlowError.encode(error)
        }
    }

    static func encodeParameters(_ parameters: [String: Any], into request: URLRequest, as encoding: EncodeParameters) throws -> URLRequest {
        var mutableRequest = request
        do {
            try mutableRequest.encode(parameters: parameters, as: encoding)
            return mutableRequest
            /// retorna a requisição após aplicar parâmetros via `query string` ou como `x-www-form-urlencoded` (URLRequest.encode)
        } catch {
            throw FlowError.encode(error)
        }
    }
    
    static func encodeBodyAndParameters(_ bodyParameters: [String: Any], _ queryParameters: [String: Any]?, into request: URLRequest) throws -> URLRequest {
        var mutableRequest = request
        
        if let queryParameters = queryParameters {
            mutableRequest = try encodeParameters(queryParameters, into: mutableRequest, as: .query)
            /// verifica o caso de `queryParameters` seja nil, assim não aplica na URL
        }
        mutableRequest.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
        /// converte o dicionário de `bodyParameters` em JSON e o atribui como corpo da requisição em `httpBody` da URL
        return mutableRequest
    }
}

private extension URLRequest {
    mutating func encode(parameters: [String: Any], as encoding: EncodeParameters) throws {
        switch encoding {
        case .http:
            let bodyString = parameters
                .map { "\($0.key)=\("\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                .joined(separator: "&")

            setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            httpBody = bodyString.data(using: .utf8)
        case .query:
            /// manipulacao para adicionar parâmetros de query string à URL que possuimos de forma segura
            guard var urlComponents = URLComponents(string: self.url?.absoluteString ?? "") else {
                throw URLError(.badURL)
            }

            /// converte cada par chave-valor do dicionário (dict) de parâmetros em um `URLQueryItem`
            /// assim sendo adicionado à query string da URL `urlComponents.queryItems = queryItems`
            let queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }

            urlComponents.queryItems = queryItems

            guard let updatedURL = urlComponents.url else {
                throw URLError(.badURL)
            }

            self.url = updatedURL
        }
    }
}

public extension Encodable {
    /// extensão para converter um objeto `Encodable` para um dicionário (dict) `[String: Any]`
    /// útil para construção dinâmica
    func toDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            print("Erro ao converter struct para dicionário: \(error)")
            return nil
        }
    }
}
