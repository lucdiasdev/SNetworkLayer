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
    
    var baseURLString: String?
    var endPointString: String?
    var httpMethodString: HTTPMethod?
    var headersString: [String: String]?
    var paramString: String?
    
    //MARK: SNetworkLayer demo example using
    var service: SetTarget?
    var snetworklayer = SNetworkLayer()
    
    init() { }
    
    func setTargetConfiguration() {
        snetworklayer.setBaseURL(url: self.baseURLString ?? "")
        let requester = Requester<SetTarget>(networkLayer: snetworklayer)
        
        service = SetTarget(path: endPointString ?? "",
                            httpMethod: httpMethodString ?? .get,
                            headers: nil,
                            task: .requestDefault,
                            requester: requester)
    }
    
    func request() {
        setTargetConfiguration()
        
//        service?.fetch()
        
        guard let service = service else { return }
        service.requester.fetch(target: service) { [weak self] result, response in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                self.delegate?.didRequestResponse(response: String(data: success, encoding: .utf8) ?? "")
            case .failure(_):
                break
            }
        }
    }
    
}
