//
//  SNetworkLayer.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//

import Foundation

public class SNetworkLayer {
    
    var baseURL: URL?
    
    public init() { }
    
    public func setBaseURL(url: String) {
        guard let url = URL(string: url) else {
            assertionFailure("failure baseURL")
            return
        }
        
        self.baseURL = url
    }
    
}
