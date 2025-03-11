//
//  ViewModelDemo.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import SNetworkLayer

enum CellsType {
    case textFieldInput
    case textBodyRequest
}

protocol ViewModelDemoDelegate: AnyObject {
    func didRequestResponse(response: String)
}

final class ViewModelDemo {
    
    //MARK: ViewControllerDemo Rules
    let cells: [CellsType] = [.textFieldInput, .textBodyRequest]
    weak var delegate: ViewModelDemoDelegate?
    
    //MARK: SNetworkLayer demo example using
    var service = APIStructService()
    
    init() {}
    
//    func setConfigureBaseURL(baseURL: String) {
//        service.setBaseURL(url: baseURL)
//    }
    
//    func setConfigureEndpoint(endpoint: String) {
//        
//    }
    
//    func setHTTPMethod(httpMethod: HTTPMethod) {
//        
//    }
    
    func fetchSNetworkLayer() {
        service.fetchAPIStruct { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                guard let model = success else { return }
                self.delegate?.didRequestResponse(response: String(data: model, encoding: .utf8) ?? "")
            case .failure(_):
                break
            }
        }
    }
    
}
