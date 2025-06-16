//
//  SNetworkLayer.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

open class SNetworkLayer<T: Target> {
     
    private let urlSession: URLSession
    private let executor: ExecutorProtocol
    
    public init(executor: ExecutorProtocol = Executor(), urlSessionConfiguration: URLSessionConfiguration) {
        self.executor = executor
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }
    
    /// inicializador que encapsula uma configuração para urlSession
    /// caso queira personalizar alguma dessas configurações, basta sobrescrever os parametros desejados
    /// suponha que voce tenha sua classe de service conforme construção utilizando o SNetworkLayer:
    /// - ex.: `Class ExampleService: SNetworkLayer<ExampleAPI>`
    /// ao inicializar a instancia do seu service você utiliza `let service = ExampleService(requestTimeOut: .long, resourceTimeOut: .short)` ou alguma propriedade a sua escolha
    public convenience init(requestTimeOut: TimeIntervalRequestType = .short, resourceTimeOut: TimeIntervalRequestType = .short,
                            urlCache: URLCache? = nil, urlCredentialStorage: URLCredentialStorage? = nil,
                            httpCookieAcceptPolicy: HTTPCookie.AcceptPolicy = .always,
                            cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
                            waitsForConnectivity: Bool = true) {
        
        let config = URLSessionConfiguration.default
        
        /// `requestTimeout` timeout para inatividade de uma requisição
        config.timeoutIntervalForRequest = requestTimeOut.rawValue
        /// `resourceTimeout` timeout total para baixar todo o recurso
        config.timeoutIntervalForResource = resourceTimeOut.rawValue
        /// `urlCache` Desabilita o cache da URLSession
        config.urlCache = urlCache
        /// `urlCredentialStorage` Desativa o armazenamento automático de credenciais (como login/senha)
        config.urlCredentialStorage = urlCredentialStorage
        /// `httpCookieAcceptPolicy` Define que a sessão deve sempre aceitar cookies de qualquer origem.``
        config.httpCookieAcceptPolicy = httpCookieAcceptPolicy
        /// `requestCachePolicy` Garante que a sessão ignora qualquer cache local ou remoto ao fazer requisições.``
        config.requestCachePolicy = cachePolicy
        /// `waitsForConnectivity` URLSession espera que a conectividade volte antes de iniciar a requisição (true)
        /// a requisição falha imediatamente com erro do tipo .notConnectedToInternet (false)
        config.waitsForConnectivity = waitsForConnectivity
        
        self.init(urlSessionConfiguration: config)
    }
    
    private func composer(_ target: T,
                          _ urlSession: URLSession,
                          completion: @escaping (_ data: Data?, _ request: URLRequest?, _ response: URLResponse?, _ error: FlowError?) -> Void) -> NetworkDataTask? {
        do {
            /// `Composer` retorna um `URLSession` a partir do `Target`
            /// cria a url a ser utilizada com seus devidos parametros
            /// promovento o encapsulamento de headers, method http e body
            let request = try ComposerTarget.composeRequest(target)
            
            return self.executor.execute(urlRequest: request, session: urlSession) { data, response, error in
                completion(data, request, response, error)
            }
        } catch {
            completion(nil, nil, nil, FlowError.invalidRequest(error))
            return nil
        }
    }
    
    private func decode<D: Decodable>(_ data: Data, to type: D.Type) throws -> D {
        do {
            return try JSONDecoder().decode(D.self, from: data)
        } catch {
            /// mapeia e imprime os detalhes do erro de decoding (`DecodingError`) para facilitar o diagnóstico.
            /// ajuda a entender exatamente o que deu errado na estrutura dos dados recebidos do backend
            /// como chaves ausentes, tipos incompatíveis ou dados corrompidos.
            /// o erro detalhado é impresso apenas em tempo de desenvolvimento (via `print`)
            if let decodingError = error as? DecodingError {
                let detailedError: String
                
                switch decodingError {
                case .keyNotFound(let key, let context):
                    detailedError = "🚨🔑 Chave não encontrada: \(key.stringValue). \nContexto: \(context.debugDescription)"
                case .typeMismatch(let type, let context):
                    detailedError = "🚨❌ Tipo incompatível: \(type). \nContexto: \(context.debugDescription)"
                case .valueNotFound(let type, let context):
                    detailedError = "🚨⚠️ Valor não encontrado para tipo: \(type). \nContexto: \(context.debugDescription)"
                case .dataCorrupted(let context):
                    detailedError = "🚨🧨 Dados corrompidos. \nContexto: \(context.debugDescription)"
                @unknown default:
                    detailedError = "🚨 Erro de decoding desconhecido: \(decodingError)"
                }
                print(detailedError)
            }
            
            throw error
        }
    }
    
    //MARK: - WITH DATA CODABLE AND ERROR CUSTOM TYPE
    @discardableResult
    private func superFetch<V: Codable, E: Error & Codable>(_ target: T,
                                                            dataType: V.Type,
                                                            errorType: E.Type,
                                                            completion: ((Result<V, FlowError>, _ response: URLResponse?) -> Void)?) -> NetworkDataTask? {
        
        let task = self.composer(target, self.urlSession) { [weak self] data, request, response, error in
            guard let self = self else { return }
            
            /// erro nativo `NetworkError` (sem internet, timeout e etc)
            if let error = error {
                if case let FlowError.network(networkError) = error {
                    if let mapper = SNetworkLayerErrorConfiguration.provider?.networkErrorMapper, let mapped = mapper(networkError) as? E {
                        /// regra aplicada para obter o mapper de erro configurado no projeto via SNetworkLayerConfiguration
                        /// se o mapeador existir e conseguir transformar o `networkError` em um erro customizado do tipo `E
                        /// retorna esse erro no completion, encapsulado em `.apiCustomError`
                        completion?(.failure(.apiCustomError(mapped)), response)
                    } else {
                        /// se não houver mapeador ou o mapeamento falhar, retorna o erro de rede padrão.
                        completion?(.failure(.network(networkError)), response)
                    }
                } else {
                    completion?(.failure(.network(.unknown)), response)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(.failure(.invalidResponse), response)
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            /// sucesso (status 2xx)
            if (200...299).contains(statusCode) {
                if let data = data {
                    do {
                        let decoded = try self.decode(data, to: V.self)
                        completion?(.success(decoded), response)
                        return
                    } catch {
                        completion?(.failure(.decode(error)), response)
                    }
                } else {
                    completion?(.failure(.noData), response)
                }
                return
            }
            
            /// fallback de error
            /// tentativa de decodificar erro customizado
            if let data = data {
                do {
                    let decodedError = try self.decode(data, to: E.self)
                    completion?(.failure(.apiCustomError(decodedError)), response)
                } catch {
                    completion?(.failure(.decode(error)), response)
                }
                return
            } else {
                completion?(.failure(.noData), response)
                return
            }
        }
        
        return task
    }
    
    /// fetch que recebe um codable `dataType` e um codable `errorType`
    @discardableResult
    public func fetch<V: Codable, E: Error & Codable>(_ target: T,
                                                      dataType: V.Type,
                                                      errorType: E.Type,
                                                      completion: @escaping (FlowResult<V, E>, _ response: URLResponse?) -> Void) -> NetworkDataTask? {
        /// encapsulamento de lógica do método `superFetch`, que reaproveita a lógica comum de requisição
        /// adiciona o mapeamento automático para o tipo de erro customizado definido pelo projeto.
        /// permite que o consumidor lide apenas com o tipo de erro `E`, sem precisar conhecer `FlowError`
        return superFetch(target, dataType: dataType, errorType: errorType) { result, response in
            switch result {
            case .success(let data):
                completion(.success(data), response)
            case .failure(let error):
                let errorType = error.as(E.self)
                errorType != nil ? nil : print("🚨 native error:\n\(error) \nconfigure SNetworkLayerConfigProvider to receive native error in cast for your errorType")
                completion(.failure(errorType), response)
            }
        }
    }
    
    //MARK: - WITH DATA CODABLE AND ERROR DEFAULT
    @discardableResult
    public func superFetch<V: Codable>(_ target: T,
                                       dataType: V.Type,
                                       completion: ((Result<V, FlowError>, _ response: URLResponse?) -> Void)?) -> NetworkDataTask? {
        
        let task = self.composer(target, self.urlSession) { [weak self] data, request, response, error in
            guard let self = self else { return }
            
            /// erro nativo `NetworkError` (sem internet, timeout e etc)
            if let error = error {
                if case let FlowError.network(networkError) = error {
                    completion?(.failure(.network(networkError)), response)
                } else {
                    completion?(.failure(.network(.unknown)), response)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(.failure(.invalidResponse), response)
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            /// sucesso (status 2xx)
            if (200...299).contains(statusCode) {
                if let data = data {
                    do {
                        let decoded = try self.decode(data, to: V.self)
                        completion?(.success(decoded), response)
                        return
                    } catch {
                        completion?(.failure(.decode(error)), response)
                    }
                } else {
                    completion?(.failure(.noData), response)
                }
                return
            }
            
            /// fallback de error
            /// tentativa de decodificar erro customizado
            if let data = data {
                completion?(.failure(.apiError(data)), response)
                return
            } else {
                completion?(.failure(.noData), response)
                return
            }
        }
        
        return task
    }
    
    /// fetch que recebe um codable `dataType` e um `Error`
    @discardableResult
    public func fetch<V: Codable>(_ target: T,
                                  dataType: V.Type,
                                  completion: @escaping (Result<V, Error>, _ response: URLResponse?) -> Void) -> NetworkDataTask? {
        /// encapsulamento de lógica do método `superFetch`, que reaproveita a lógica comum de requisição
        /// adiciona o mapeamento para o tipo de resposta customizado definido pelo projeto.
        /// permite que o consumidor lide apenas com o tipo de resposta `V`
        return superFetch(target, dataType: dataType) { result, response in
            switch result {
            case .success(let data):
                completion(.success(data), response)
            case .failure(let error):
                completion(.failure(error), response)
            }
        }
    }
    
    //MARK: - WITH DATA DEFAULT AND ERROR CUSTOM TYPE
    @discardableResult
    private func superFetch<E: Error & Codable>(_ target: T,
                                                errorType: E.Type,
                                                completion: ((Result<Data, FlowError>, _ response: URLResponse?) -> Void)?) -> NetworkDataTask? {
        
        let task = self.composer(target, self.urlSession) { [weak self] data, request, response, error in
            guard let self = self else { return }
            
            /// erro nativo `NetworkError` (sem internet, timeout e etc)
            if let error = error {
                if case let FlowError.network(networkError) = error {
                    if let mapper = SNetworkLayerErrorConfiguration.provider?.networkErrorMapper, let mapped = mapper(networkError) as? E {
                        /// regra aplicada para obter o mapper de erro configurado no projeto via SNetworkLayerConfiguration
                        /// se o mapeador existir e conseguir transformar o `networkError` em um erro customizado do tipo `E
                        /// retorna esse erro no completion, encapsulado em `.apiCustomError`
                        completion?(.failure(.apiCustomError(mapped)), response)
                    } else {
                        /// se não houver mapeador ou o mapeamento falhar, retorna o erro de rede padrão.
                        completion?(.failure(.network(networkError)), response)
                    }
                } else {
                    completion?(.failure(.network(.unknown)), response)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(.failure(.invalidResponse), response)
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            /// sucesso (status 2xx)
            if (200...299).contains(statusCode) {
                if let data = data {
                    completion?(.success(data), response)
                } else {
                    completion?(.failure(.noData), response)
                }
                return
            }
            
            /// fallback de error
            /// tentativa de decodificar erro customizado
            if let data = data {
                do {
                    let decodedError = try self.decode(data, to: errorType.self)
                    completion?(.failure(.apiCustomError(decodedError)), response)
                } catch {
                    completion?(.failure(.decode(error)), response)
                }
                return
            } else {
                completion?(.failure(.noData), response)
                return
            }
        }
        
        return task
    }
    
    /// fetch que recebe um `Data` e um codable `errorType`
    @discardableResult
    public func fetch<E: Error & Codable>(_ target: T,
                                          errorType: E.Type,
                                          completion: @escaping (FlowResult<Data, E>, _ response: URLResponse?) -> Void) -> NetworkDataTask? {
        /// encapsulamento de lógica do método `superFetch`, que reaproveita a lógica comum de requisição
        /// adiciona o mapeamento automático para o tipo de erro customizado definido pelo projeto.
        /// permite que o consumidor lide apenas com o tipo de erro `E`, sem precisar conhecer `FlowError`
        return superFetch(target, errorType: errorType) { result, response in
            switch result {
            case .success(let data):
                completion(.success(data), response)
            case .failure(let error):
                let errorType = error.as(E.self)
                errorType != nil ? nil : print("🚨 native error:\n\(error) \nconfigure SNetworkLayerConfigProvider to receive native error in cast for your errorType")
                completion(.failure(errorType), response)
            }
        }
    }
    
    //MARK: - WITH DATA DEFAULT AND ERROR DEFAULT
    @discardableResult
    public func superFetch(_ target: T,
                           completion: ((Result<Data, FlowError>, _ response: URLResponse?) -> Void)?) -> NetworkDataTask? {
        
        let task = self.composer(target, self.urlSession) { [weak self] data, request, response, error in
            guard let _ = self else { return }
            
            /// erro nativo `NetworkError` (sem internet, timeout e etc)
            if let error = error {
                if case let FlowError.network(networkError) = error {
                    completion?(.failure(.network(networkError)), response)
                } else {
                    completion?(.failure(.network(.unknown)), response)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(.failure(.invalidResponse), response)
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            /// sucesso (status 2xx)
            if (200...299).contains(statusCode) {
                if let data = data {
                    completion?(.success(data), response)
                } else {
                    completion?(.failure(.noData), response)
                }
                return
            }
            
            /// fallback de error (nao existe um `custom error` neste fetch)
            if let data = data {
                completion?(.failure(.apiError(data)), response)
                return
            } else {
                completion?(.failure(.noData), response)
                return
            }
            
        }
        
        return task
    }
    
    /// fetch que recebe um `Data` e um `Error`
    @discardableResult
    public func fetch(_ target: T,
                      completion: @escaping (Result<Data, Error>, _ response: URLResponse?) -> Void) -> NetworkDataTask? {
        /// encapsulamento de lógica do método `superFetch`, que reaproveita a lógica comum de requisição
        return superFetch(target) { result, response in
            switch result {
            case .success(let data):
                completion(.success(data), response)
            case .failure(let error):
                completion(.failure(error), response)
            }
        }
    }
}
