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
    case selectionHttpMethod
    case writeHeaders
    case queryParam
    case bodyParam
}

class ViewModelDemo {
    
    let cells: [CellsType] = [.textFieldInput, .selectionHttpMethod, .writeHeaders, .queryParam, .bodyParam]
    let httpMethod: [HTTPMethod] = [.get, .post]
    
    init() { }
    
}
