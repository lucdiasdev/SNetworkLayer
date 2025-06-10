//
//  SNetworkLayerTests.swift
//  SNetworkLayer_Tests
//
//  Created by Lucas Rodrigues Dias on 05/06/25.
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
    public init() {
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

final class SNetworkLayerTests: XCTestCase {
    
    struct MockTarget: Target {
        var baseURL = URL(string: "https://api.test.com")!
        var path = "/test"
        var httpMethod: HTTPMethod = .get
        var headerParamaters: [String : String]? = ["Header": "Value"]
        var task: Task = .requestDefault
    }
    
    struct MockModel: Codable, Equatable {
        let id: Int
        let test: String
    }
    
    struct MockErrorModel: Error, Codable, Equatable {
        let id: Int
        let error: String
        let test: String
    }
    
    struct ConfigProviderErrorNetworkTest: SNetworkLayerErrorNetworkConfigProvider {
        static var networkErrorMapper: ((NetworkError) -> (any Error & Codable)?)? = { error in
            switch error {
            case .unknown:
                return MockErrorModel(id: 321, error: "error custom decodable unknown", test: "should return success decoded model - fetch with data codable and error custom type")
            case .timeOut:
                return MockErrorModel(id: 321, error: "error custom decodable timeOut", test: "should return success decoded model - fetch with data codable and error custom type")
            case .notConnectedNetwork:
                return MockErrorModel(id: 321, error: "error custom decodable notConnectedNetwork", test: "should return success decoded model - fetch with data codable and error custom type")
            case .lostConnectedNetwork:
                return MockErrorModel(id: 321, error: "error custom decodable lostConnectedNetwork", test: "should return success decoded model - fetch with data codable and error custom type")
            case .cancelConnectedNetwork:
                return MockErrorModel(id: 321, error: "error custom decodable cancelConnectedNetwork", test: "should return success decoded model - fetch with data codable and error custom type")
            }
        }
    }
    
    var executorSpy: ExecutorSpy!
    var sut: SNetworkLayer<MockTarget>!
    
    override func setUp() {
        super.setUp()
        executorSpy = ExecutorSpy()
        sut = SNetworkLayer<MockTarget>(executor: executorSpy, urlSessionConfiguration: .default)
    }
    
    override func tearDown() {
        executorSpy = nil
        sut = nil
        super.tearDown()
    }

    func test_fetch_success_shouldReturnDecodedModel() {
        // Arrange
        let mockData = try! JSONEncoder().encode(MockModel(id: 123, test: "should return success decoded model - fetch with data codable and error custom type"))
        let mockResponse = HTTPURLResponse(url: MockTarget().baseURL,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)
        
        executorSpy.mockData = mockData
        executorSpy.mockResponse = mockResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success(let model):
                XCTAssertEqual(model, MockModel(id: 123, test: "should return success decoded model - fetch with data codable and error custom type"))
            case .failure:
                XCTFail("Should not fail")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Verifica se o Executor foi chamado corretamente
        XCTAssertEqual(executorSpy.executeCallCount, 1)
        XCTAssertEqual(executorSpy.lastURLRequest?.url, MockTarget().baseURL.appendingPathComponent("/test"))
        XCTAssertEqual(executorSpy.lastURLRequest?.httpMethod, "GET")
    }
    
    func test_fetch_error_shouldReturnDecodedErrorModel() {
        // Arrange
        let errorData = try! JSONEncoder().encode(MockErrorModel(id: 321, error: "error custom decodable", test: "should return error decoded model - fetch with data codable and error custom type"))
        let errorResponse = HTTPURLResponse(url: MockTarget().baseURL,
                                            statusCode: 401,
                                            httpVersion: nil,
                                            headerFields: nil)
        
        executorSpy.mockData = errorData
        executorSpy.mockResponse = errorResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, MockErrorModel(id: 321, error: "error custom decodable", test: "should return error decoded model - fetch with data codable and error custom type"))
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Verifica se o Executor foi chamado corretamente
        XCTAssertEqual(executorSpy.executeCallCount, 1)
        XCTAssertEqual(executorSpy.lastURLRequest?.url, MockTarget().baseURL.appendingPathComponent("/test"))
        XCTAssertEqual(executorSpy.lastURLRequest?.httpMethod, "GET")
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_timeOut() {
        // Arrange
        executorSpy.mockError = .network(.timeOut) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
                /// retorna nil pois o `custom error` nao entende erros de network nativo para feedback
                /// por este motivo existe a doc para utilizar o `SNetworkLayerErrorNetworkConfigProvider`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_withSNetworkLayerErrorNetworkConfigProvider_timeOut() {
        // Arrange
        executorSpy.mockError = .network(.timeOut) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, MockErrorModel(id: 321, error: "error custom decodable timeOut", test: "should return success decoded model - fetch with data codable and error custom type"))
                /// retorna  o `custom error` configurado no `SNetworkLayerErrorNetworkConfigProvider`
                /// pois existe a aplicação de `SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_notConnectedNetwork() {
        // Arrange
        executorSpy.mockError = .network(.notConnectedNetwork) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
                /// retorna nil pois o `custom error` nao entende erros de network nativo para feedback
                /// por este motivo existe a doc para utilizar o `SNetworkLayerErrorNetworkConfigProvider`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_withSNetworkLayerErrorNetworkConfigProvider_notConnectedNetwork() {
        // Arrange
        executorSpy.mockError = .network(.notConnectedNetwork) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, MockErrorModel(id: 321, error: "error custom decodable notConnectedNetwork", test: "should return success decoded model - fetch with data codable and error custom type"))
                /// retorna  o `custom error` configurado no `SNetworkLayerErrorNetworkConfigProvider`
                /// pois existe a aplicação de `SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_cancelConnectedNetwork() {
        // Arrange
        executorSpy.mockError = .network(.cancelConnectedNetwork) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
                /// retorna nil pois o `custom error` nao entende erros de network nativo para feedback
                /// por este motivo existe a doc para utilizar o `SNetworkLayerErrorNetworkConfigProvider`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_withSNetworkLayerErrorNetworkConfigProvider_cancelConnectedNetwork() {
        // Arrange
        executorSpy.mockError = .network(.cancelConnectedNetwork) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, MockErrorModel(id: 321, error: "error custom decodable cancelConnectedNetwork", test: "should return success decoded model - fetch with data codable and error custom type"))
                /// retorna  o `custom error` configurado no `SNetworkLayerErrorNetworkConfigProvider`
                /// pois existe a aplicação de `SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_lostConnectedNetwork() {
        // Arrange
        executorSpy.mockError = .network(.lostConnectedNetwork) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
                /// retorna nil pois o `custom error` nao entende erros de network nativo para feedback
                /// por este motivo existe a doc para utilizar o `SNetworkLayerErrorNetworkConfigProvider`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_withSNetworkLayerErrorNetworkConfigProvider_lostConnectedNetwork() {
        // Arrange
        executorSpy.mockError = .network(.lostConnectedNetwork) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, MockErrorModel(id: 321, error: "error custom decodable lostConnectedNetwork", test: "should return success decoded model - fetch with data codable and error custom type"))
                /// retorna  o `custom error` configurado no `SNetworkLayerErrorNetworkConfigProvider`
                /// pois existe a aplicação de `SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_unknown() {
        // Arrange
        executorSpy.mockError = .network(.unknown) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
                /// retorna nil pois o `custom error` nao entende erros de network nativo para feedback
                /// por este motivo existe a doc para utilizar o `SNetworkLayerErrorNetworkConfigProvider`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_withSNetworkLayerErrorNetworkConfigProvider_unknown() {
        // Arrange
        executorSpy.mockError = .network(.unknown) // Simula timeout
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        // Act
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            // Assert
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, MockErrorModel(id: 321, error: "error custom decodable unknown", test: "should return success decoded model - fetch with data codable and error custom type"))
                /// retorna  o `custom error` configurado no `SNetworkLayerErrorNetworkConfigProvider`
                /// pois existe a aplicação de `SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self`
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
