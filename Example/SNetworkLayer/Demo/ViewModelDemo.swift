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
    
    struct TaskPickerItem {
        let label: String
        let task: Task
    }
    
    let taskPickerItems: [TaskPickerItem] = [TaskPickerItem(label: "defaultRequest", task: .requestDefault),
                                             TaskPickerItem(label: "requestBodyEncodable(Encodable)", task: .requestBodyEncodable(EmptyEncodable())),
                                             TaskPickerItem(label: "requestParametersHttp", task: .requestParameters(parameters: [:], encodeParameters: .http)),
                                             TaskPickerItem(label: "requestParametersQuery", task: .requestParameters(parameters: [:], encodeParameters: .query)),
                                             TaskPickerItem(label: "requestParametersBodyWithQuery", task: .requestParameters(parameters: [:], encodeParameters: .bodyWithQuery))]
    
    struct EmptyEncodable: Encodable {
        
    }
    
    weak var delegate: ViewModelDemoDelegate?
    
///MARK:  `para documentacao` mostrando como iniciar o servicing
    var service = APIStructService()
    
    init() { }
    
    func addingHeaderParams() {
        
    }
    
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
