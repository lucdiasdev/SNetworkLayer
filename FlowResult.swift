//
//  FlowResult.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 23/05/25.
//

import Foundation

public enum FlowFailure: Error {
    case custom(Codable & Error)
    case system(Error)
}

public enum FlowResult<S: Codable, E: Error> {
    case success(S)
    case failure(FlowFailure)
    
    func mapResult() -> Result<S, FlowFailure> {
        switch self {
        case .success(let codable):
            return .success(codable)
        case .failure(let error):
            return .failure(error)
        }
    }
}
