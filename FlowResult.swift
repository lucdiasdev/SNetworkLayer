//
//  FlowResult.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 23/05/25.
//

import Foundation

//public enum FlowFailure: Error {
//    case custom(Codable & Error)
//    case system(FlowError)
//}

public enum FlowResult<S: Codable, E: Error & Codable> {
    case success(S)
    case failure(E)
    
    func mapResult() -> Result<S, E> {
        switch self {
        case .success(let codable):
            return .success(codable)
        case .failure(let error):
            return .failure(error)
        }
    }
}
