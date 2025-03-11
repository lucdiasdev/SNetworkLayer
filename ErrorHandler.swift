//
//  ErrorHandler.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

//MARK: - NetworkError
public enum NetworkError: Error {
    case network(Error)
    case api(GenericError) ///validar forma de dev inputar o BFF de error dele
    case parse(Error?)
    case other(GenericError) ///validar forma de dev inputar o BFF de error dele
    case unknown
}

//MARK: - ServiceNetworkError
public enum ServiceNetworkError: Error {
    case unknown(Error?)
    case cancelled(Error?)
    case badURL(Error?)
    case timedOut(Error?)
    case unsupportedURL(Error?)
    case cannotFindHost(Error?)
    case cannotConnectToHost(Error?)
    case networkConnectionLost(Error?)
    case lookupFailed(Error?)
    case tooManyRedirects(Error?)
    case resourceUnavailable(Error?)
    case notConnectedToInternet(Error?)
}

//MARK: - FlowError
protocol FlowErrorProtocol: LocalizedError {
//    var code: Int { get }
    var underlyingError: Error? { get }
}

public enum FlowError: Error {
    case invalidURL
    case encode(Error)
    case network(Error)
    case invalidRequest(Error)
    case invalidBody(Error)
    case invalidParameters
}

extension FlowError: FlowErrorProtocol {
//    var code: Int {
//        <#code#>
//    }
    
    var underlyingError: Error? {
        switch self {
        case .invalidURL, .invalidParameters:
            return nil
        case .encode(let error):
            return error
        case .network(let error):
            return error
        case .invalidRequest(let error):
            return error
        case .invalidBody(let error):
            return error
        }
    }
}

public struct APIErrorResponse: Codable {
    public var errors: [APIError]
    
    public var error: APIError? {
        return errors.first
    }
}

public struct APIError: Codable, GenericError {
    public var code = 0
    public var message = ""
    public var context: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case context
    }

    public var errorDescription: String? { message }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stringCode = try container.decode(String.self, forKey: .code)
        code = Int(stringCode) ?? -1
        message = try container.decode(String.self, forKey: .message)
        if container.contains(.context) {
            context = try container.decode(String?.self, forKey: .context)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)
        try container.encode(context, forKey: .context)
    }
}

public struct ValidationError: GenericError {
    public let statusCode: Int
    public let underlyingError: Error?
    public let code: Int
    public let message: String
    public let context: String?

    public var errorDescription: String? {
        return "\(statusCode) | \((underlyingError ?? NetworkError.unknown).localizedDescription)"
    }

    init(_ error: Error?, statusCode: Int) {
        self.statusCode = statusCode
        self.underlyingError = error
        let underlying = (error as? GenericError)
        self.code = underlying?.code ?? 0000
        self.message = underlying?.message ?? "underlying message is nil, is value has optional"
        self.context = underlying?.context
    }
}

public protocol GenericError: LocalizedError {
    var code: Int { get }
    var message: String { get }
    var context: String? { get }
    var underlyingError: Error? { get }
}

public extension GenericError {
    var context: String? { return nil }
    var underlyingError: Error? { return nil }
}

public extension GenericError where Self: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.code == rhs.code
    }
    
    static func == (lhs: Self, rhs: GenericError) -> Bool {
        return lhs.code == rhs.code
    }
}

///Use
///NSError.defaultDomain = ""
///NSError.code = 0
///NSError.description = ""
extension NSError {
    private static var defaultDomain = "DataNotFound"
    private static var defaultCode = -1
    private static var defaultDescription = "The server response contains no data."
    
    public static var domain: String {
        get { defaultDomain }
        set { defaultDomain = newValue }
    }
    
    public static var code: Int {
        get { defaultCode }
        set { defaultCode = newValue }
    }
    
    public static var description: String {
        get { defaultDescription }
        set { defaultDescription = newValue }
    }
    
    static func dataNotFound() -> NSError {
        return NSError(domain: defaultDomain,
                       code: defaultCode,
                       userInfo: [NSLocalizedDescriptionKey: defaultDescription])
    }
}
