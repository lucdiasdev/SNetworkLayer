//
//  SetTarget.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 11/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import SNetworkLayer

final class SetTarget: Target {
    
    var requester: Requester<SetTarget>
    
    var path: String
    var httpMethod: HTTPMethod
    var headers: [String: String]?
    var task: Task
    
    init(path: String, httpMethod: HTTPMethod, headers: [String: String]?, task: Task, requester: Requester<SetTarget>) {
        self.path = path
        self.httpMethod = httpMethod
        self.headers = headers
        self.task = task
        self.requester = requester
    }
    
    func fetch() {
        requester.fetch(target: self) { result, _ in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
        
//        requester.fetch(target: self, dataType: Welcome.self) { result, _ in
//            switch result {
//            case .success(let success):
//                print(success)
//            case .failure(let failure):
//                print(failure)
//            }
//        }
    }
}

struct Welcome: Codable {
    let name: String
    let id: Int
    let height: Int
    let weight: Int
}
