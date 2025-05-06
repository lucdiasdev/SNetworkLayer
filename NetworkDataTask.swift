//
//  NetworkDataTask.swift
//  SNetworkLayer
//
//  Created by Lucas Rodrigues Dias on 07/04/25.
//

import Foundation

public final class NetworkDataTask {
    private let task: URLSessionDataTask?
    
    init(task: URLSessionDataTask?) {
        self.task = task
    }
    
    public func cancel() {
        task?.cancel()
    }
    
    public func suspend() {
        task?.suspend()
    }
    
    public func resume() {
        task?.resume()
    }
    
    public var state: URLSessionTask.State? {
        return task?.state
    }
}
