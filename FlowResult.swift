//
//  FlowResult.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 23/05/25.
//

import Foundation

public enum FlowResult<S: Codable, E: Error & Codable> {
    case success(S)
    case failure(E?)
}
