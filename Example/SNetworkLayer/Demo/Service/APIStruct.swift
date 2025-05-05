//
//  APIStruct.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 19/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import SNetworkLayer

enum APIStruct {
    case detailsPokemon
}

extension APIStruct: Target {    
    var headerParamaters: [String : String]? {
        return nil
    }
    
    var path: String {
        switch self {
        case .detailsPokemon:
            return "v1/users"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .detailsPokemon:
            return .get
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .detailsPokemon:
            return nil
        }
    }
    
    var task: Task {
        switch self {
        case .detailsPokemon:
            return .requestDefault
        }
    }
}

final class APIStructService: SNetworkLayer<APIStruct> {
    var statusCode: Int?
    
    func fetchAPIStruct(completion: @escaping (Result<Data, FlowError>) -> Void) {

        fetch(.detailsPokemon) { result, response in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            self.statusCode = httpResponse.statusCode
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
