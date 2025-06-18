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
    
    struct MockModelErrorDecodable: Error, Codable, Equatable {
        let error: String
    }
    
    struct MockErrorModel: Error, Codable, Equatable {
        let id: Int
        let error: String
        let test: String
    }
    
    struct ConfigProviderErrorNetworkTest: SNetworkLayerErrorNetworkConfigProvider {
        static var decodableErrorMapper: ((DecodingError) -> (any Error & Codable)?)? = { decodingError in
            switch decodingError {
            case .keyNotFound(let key, let context):
                return MockErrorModel(id: 123, error: "keyNotFound", test: "")
            case .typeMismatch(let type, let context):
                return MockErrorModel(id: 123, error: "typeMismatch", test: "")
            case .valueNotFound(let type, let context):
                return MockErrorModel(id: 123, error: "valueNotFound", test: "")
            case .dataCorrupted(let context):
                return MockErrorModel(id: 123, error: "dataCorrupted", test: "")
            default:
                return MockErrorModel(id: 123, error: "unknown", test: "")
            }
        }
        
        
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
    
    //MARK: - TESTS FETCH WITH DATA CODABLE AND ERROR CUSTOM TYPE

    func test_fetch_success_shouldReturnDecodedModel() {
        let mockData = try! JSONEncoder().encode(MockModel(id: 123, test: "should return success decoded model - fetch with data codable and error custom type"))
        let mockResponse = HTTPURLResponse(url: MockTarget().baseURL,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)
        
        executorSpy.mockData = mockData
        executorSpy.mockResponse = mockResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success(let model):
                XCTAssertEqual(model, MockModel(id: 123, test: "should return success decoded model - fetch with data codable and error custom type"))
            case .failure:
                XCTFail("Should not fail")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        /// verifica se o `Executor` foi chamado corretamente
        XCTAssertEqual(executorSpy.executeCallCount, 1)
        XCTAssertEqual(executorSpy.lastURLRequest?.url, MockTarget().baseURL.appendingPathComponent("/test"))
        XCTAssertEqual(executorSpy.lastURLRequest?.httpMethod, "GET")
    }
    
    func test_fetch_error_shouldReturnDecodedErrorModel() {
        let errorData = try! JSONEncoder().encode(MockErrorModel(id: 321, error: "error custom decodable", test: "should return error decoded model - fetch with data codable and error custom type"))
        let errorResponse = HTTPURLResponse(url: MockTarget().baseURL,
                                            statusCode: 401,
                                            httpVersion: nil,
                                            headerFields: nil)
        
        executorSpy.mockData = errorData
        executorSpy.mockResponse = errorResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, MockErrorModel(id: 321, error: "error custom decodable", test: "should return error decoded model - fetch with data codable and error custom type"))
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        /// verifica se o `Executor` foi chamado corretamente
        XCTAssertEqual(executorSpy.executeCallCount, 1)
        XCTAssertEqual(executorSpy.lastURLRequest?.url, MockTarget().baseURL.appendingPathComponent("/test"))
        XCTAssertEqual(executorSpy.lastURLRequest?.httpMethod, "GET")
    }
    
    func test_fetch_networkError_shouldReturnNetworkError_timeOut() {
        // simula timeout
        executorSpy.mockError = .network(.timeOut)
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
        // simula timeout
        executorSpy.mockError = .network(.timeOut)
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
        // simula notConnectedNetwork
        executorSpy.mockError = .network(.notConnectedNetwork)
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
        // simula notConnectedNetwork
        executorSpy.mockError = .network(.notConnectedNetwork)
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
        // simula cancelConnectedNetwork
        executorSpy.mockError = .network(.cancelConnectedNetwork)
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
        // simula cancelConnectedNetwork
        executorSpy.mockError = .network(.cancelConnectedNetwork)
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
        // simula lostConnectedNetwork
        executorSpy.mockError = .network(.lostConnectedNetwork)
        
        let expectation = self.expectation(description: "Completion called")
    
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
        // simula lostConnectedNetwork
        executorSpy.mockError = .network(.lostConnectedNetwork)
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
        // simula unknown
        executorSpy.mockError = .network(.unknown)
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
        // simula unknown
        executorSpy.mockError = .network(.unknown)
        
        let expectation = self.expectation(description: "Completion called")
        
        SNetworkLayerErrorConfiguration.provider = ConfigProviderErrorNetworkTest.self
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
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
    
    func test_fetch_networkError_shouldReturnNetworkError_unknownCaseFlowErrorNetwork() {
        executorSpy.mockError = .unknown
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_invalidData_shouldReturnDecodedModel_dataCorrupted() {
        // Data não decodificável (.dataCorrupted) `statusCode 200`
        let invalidData = Data("invalid json".utf8)
        let validResponse = HTTPURLResponse(url: MockTarget().baseURL,
                                            statusCode: 200,
                                            httpVersion: nil,
                                            headerFields: nil)
        
        executorSpy.mockData = invalidData
        executorSpy.mockResponse = validResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_invalidData_shouldReturnDecodedModel_keyNotFound() {
        // chave não encontrada (.keyNotFound) `statusCode 200`
        let invalidData = """
                          {
                          "id": 99,
                          "tester": "test"
                          }
                          """.data(using: .utf8)
        let validResponse = HTTPURLResponse(url: MockTarget().baseURL,
                                            statusCode: 200,
                                            httpVersion: nil,
                                            headerFields: nil)
        
        executorSpy.mockData = invalidData
        executorSpy.mockResponse = validResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_invalidData_shouldReturnDecodedModel_typeMismatch() {
        // tipo incompatível (.typeMismatch) `statusCode 200`
        let invalidData = """
                          {
                          "id": 99,
                          "test": 99
                          }
                          """.data(using: .utf8)
        let validResponse = HTTPURLResponse(url: MockTarget().baseURL,
                                            statusCode: 200,
                                            httpVersion: nil,
                                            headerFields: nil)
        
        executorSpy.mockData = invalidData
        executorSpy.mockResponse = validResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_invalidData_shouldReturnDecodedModel_valueNotFound() {
        // valor não encontrado para tipo (.valueNotFound) `statusCode 200`
        let invalidData = """
                          {
                          "id": 99,
                          "test": null
                          }
                          """.data(using: .utf8)
        let validResponse = HTTPURLResponse(url: MockTarget().baseURL,
                                            statusCode: 200,
                                            httpVersion: nil,
                                            headerFields: nil)
        
        executorSpy.mockData = invalidData
        executorSpy.mockResponse = validResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_invalidData_shouldReturnDecodeError_dataCorrupted() {
        // Data não decodificável (.dataCorrupted) `statusCode 401`
        let invalidData = Data("invalid json".utf8)
        let validResponse = HTTPURLResponse(url: MockTarget().baseURL,
                                            statusCode: 401,
                                            httpVersion: nil,
                                            headerFields: nil)
        
        executorSpy.mockData = invalidData
        executorSpy.mockResponse = validResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_noData_shouldReturnNoDataSuccess() {
        let validResponse = HTTPURLResponse(
            url: MockTarget().baseURL,
            statusCode: 204, /// no content `Data`
            httpVersion: nil,
            headerFields: nil
        )
        
        executorSpy.mockData = nil
        executorSpy.mockResponse = validResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_noData_shouldReturnNoDataError() {
        let validResponse = HTTPURLResponse(
            url: MockTarget().baseURL,
            statusCode: 401, /// no content `Error/Data`
            httpVersion: nil,
            headerFields: nil
        )
        
        executorSpy.mockData = nil
        executorSpy.mockResponse = validResponse
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertEqual(error, nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetch_response_shouldReturnResponseNil() {
        executorSpy.mockResponse = nil
        
        let expectation = self.expectation(description: "Completion called")
        
        _ = sut.fetch(MockTarget(), dataType: MockModel.self, errorType: MockErrorModel.self) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not fail")
            case .failure(let error):
                XCTAssertEqual(error, nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        /// verifica se o `Executor` foi chamado corretamente
        XCTAssertEqual(executorSpy.executeCallCount, 1)
        XCTAssertEqual(executorSpy.lastURLRequest?.url, MockTarget().baseURL.appendingPathComponent("/test"))
        XCTAssertEqual(executorSpy.lastURLRequest?.httpMethod, "GET")
    }
    
}
