//
//  SetTarget.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 11/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import SNetworkLayer

//final class SetTarget: Target {
//    
//    var requester: SNetworkLayer<SetTarget>
//    
//    var path: String
//    var httpMethod: HTTPMethod
//    var headers: [String: String]?
//    var task: Task
//    
//    init(path: String, httpMethod: HTTPMethod, headers: [String: String]?, task: Task, requester: SNetworkLayer<SetTarget>) {
//        self.path = path
//        self.httpMethod = httpMethod
//        self.headers = headers
//        self.task = task
//        self.requester = requester
//    }
//    
//    func fetch() {
//        requester.fetch(target: self) { result, _ in
//            switch result {
//            case .success(let success):
//                print(success)
//            case .failure(let failure):
//                print(failure)
//            }
//        }
//    }
//    
//}
