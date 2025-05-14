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
            /// `.query` `.http` `.bodyWithQuery`
            /// `URLRequestBuilder.encodeParameters` retorna a URLRequest com parametros em base no tipo de codificação (encoding) citado acima
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
            
            if encoding == .bodyWithQuery {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
                mutableRequest.httpBody = data
                mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                return mutableRequest
                /// Retorna a requisição com os parâmetros inseridos no corpo como JSON, além de definir o header `Content-Type`
            } else {
                return mutableRequest
                /// Retorna a requisição após aplicar parâmetros via query string ou como `x-www-form-urlencoded` (URLRequest.encode)
                //TODO: inserir como ficaria a requisicao com parametros, criar um example
            }
        } catch {
            throw FlowError.encode(error)
        }
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
        case .query, .bodyWithQuery:
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

extension Encodable {
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
