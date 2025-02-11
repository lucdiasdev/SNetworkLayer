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
}

final class ViewModelDemo {
    
    //MARK: ViewControllerDemo Rules
    let cells: [CellsType] = [.textFieldInput]
    var baseURLString: String?
    var endPointString: String?
    var httpMethodString: HTTPMethod?
    var headersString: [String: String]?
    var paramString: String?
    
    //MARK: SNetworkLayer demo example using
    var service: SetTarget?
    var snetworklayer = SNetworkLayer()
    
    init() {

    }
    
    func setTargetConfiguration() {
        snetworklayer.setBaseURL(url: self.baseURLString ?? "")
        let requester = RequesterClassic<SetTarget>(networkLayer: snetworklayer)
        
        service = SetTarget(path: endPointString ?? "",
                            httpMethod: httpMethodString ?? .get,
                            headers: nil,
                            task: .requestDefault,
                            requester: requester)
    }
    
    func request() {
        setTargetConfiguration()
        
        service?.fetch()
    }
    
}
