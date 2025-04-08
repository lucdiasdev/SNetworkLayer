//
//  NetworkTimeInterval.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 07/04/25.
//

import Foundation

public enum NetworkTimeInterval {
    public static func configTimeInverval(requestTimeout: TimeInterval = 15,
                                          resourceTimeout: TimeInterval = 60) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = requestTimeout
        config.timeoutIntervalForResource = resourceTimeout
        return config
    }
}
