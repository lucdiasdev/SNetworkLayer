//
//  SNetworkLayerSpys.swift
//  SNetworkLayer_Tests
//
//  Created by Lucas Rodrigues Dias on 11/06/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import XCTest
import Foundation
@testable import SNetworkLayer

// Spy para simular o comportamento do Executor
class ExecutorSpy: ExecutorProtocol {
    
    // MARK: Propriedades para verificação
    private(set) var executeCallCount = 0
    private(set) var lastURLRequest: URLRequest?
    private(set) var lastSession: URLSession?
    
    // MARK: Propriedades para controle do teste
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: FlowError?
    var shouldInvokeCompletion: Bool = true
    
    // MARK: ExecutorProtocol
    func execute(urlRequest: URLRequest, session: URLSession, completion: @escaping (Data?, URLResponse?, FlowError?) -> Void) -> NetworkDataTask {
        executeCallCount += 1
        lastURLRequest = urlRequest
        lastSession = session
        
        if shouldInvokeCompletion {
            completion(mockData, mockResponse, mockError)
        }
        
        return NetworkDataTaskSpy() // Usamos um Spy para NetworkDataTask
    }
}

// Spy para NetworkDataTask (opcional, mas útil para testes de cancelamento)
class NetworkDataTaskSpy: NetworkDataTask {
    // registro das chamadas
    private(set) var cancelCallCount = 0
    private(set) var suspendCallCount = 0
    private(set) var resumeCallCount = 0
    
    // estado controlável para testes
    var mockState: URLSessionTask.State = .suspended
    
    // inicializador vazio (não precisa de URLSessionDataTask real)
    init() {
        super.init(task: URLSessionDataTask())
    }
    
    // MARK: Métodos sobrescritos
    public override func cancel() {
        cancelCallCount += 1
        mockState = .canceling
    }
    
    public override func suspend() {
        suspendCallCount += 1
        mockState = .suspended
    }
    
    public override func resume() {
        resumeCallCount += 1
        mockState = .running
    }
    
    // sobrescrevendo a propriedade `state` para retornar o estado mockado
    public override var state: URLSessionTask.State? {
        return mockState
    }
}
