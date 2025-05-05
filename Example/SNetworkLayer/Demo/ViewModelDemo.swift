//
//  ViewModelDemo.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import SNetworkLayer

protocol ViewModelDemoDelegate: AnyObject {
    func didRequestResponseSuccess(response: String, statusCode: Int)
    func didRequestResponseFailure(error: Error, statusCode: Int)
}

final class ViewModelDemo {
    
    weak var delegate: ViewModelDemoDelegate?
    
///MARK:  `para documentacao` mostrando como iniciar o servicing
    var service = APIStructService()
    
    init() { }
    
///MARK:  `para documentacao` mostrando como realizar a ação da request
    func fetchSNetworkLayer() {
        service.fetchAPIStruct { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                self.delegate?.didRequestResponseSuccess(response: String(data: success, encoding: .utf8) ?? "",
                                                         statusCode: service.statusCode ?? 000)
            case .failure(let error):
                self.delegate?.didRequestResponseFailure(error: error,
                                                         statusCode: service.statusCode ?? 000)
            }
        }
    }
    
}
