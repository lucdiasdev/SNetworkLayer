//
//  FlowResult.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 23/05/25.
//

import Foundation

//public enum FlowFailure: Error, Codable {
//    case custom(Codable & Error)
//    case system(FlowError)
//}

public enum FlowResult<S: Codable, E: Error & Codable> {
    case success(S)
    case failure(E?)
}
