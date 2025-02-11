//
//  API+Service.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 11/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import SNetworkLayer

final class SetTarget: Target {
    
    var requester: RequesterClassic<SetTarget>
    
    var path: String
    var httpMethod: HTTPMethod
    var headers: [String: String]?
    var task: Task
    
    init(path: String, httpMethod: HTTPMethod, headers: [String: String]?, task: Task, requester: RequesterClassic<SetTarget>) {
        self.path = path
        self.httpMethod = httpMethod
        self.headers = headers
        self.task = task
        self.requester = requester
    }
    
    func fetch() {
        requester.fetch(target: self, dataType: Welcome.self) { result, _ in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
//    func fetchPokeList(completion: @escaping (Result<Data, Error>) -> Void) {
//        fetch(target: .pokemonList, dataType: Data.self) { result, _ in
//            switch result {
//            case .success(let success):
//                print(success)
//            case .failure(let failure):
//                print(failure)
//            }
//        }
//    }
}

//enum API {
//    case pokemonList
//}
//
//extension API: Target {
//    var path: String {
//        switch self {
//        case .pokemonList:
//            return "pokemon/ditto"
//        }
//    }
//    
//    var httpMethod: HTTPMethod {
//        switch self {
//        case .pokemonList:
//            return .get
//        }
//    }
//    
//    var headers: [String : String]? {
//        switch self {
//        case .pokemonList:
//            return nil
//        }
//    }
//    
//    var task: Task {
//        switch self {
//        case .pokemonList:
//            return .requestDefault
//        }
//    }
//}
//
struct Welcome: Codable {
    let name: String
    let id: Int
    let height: Int
    let weight: Int
}
//
//class APIService: RequesterClassic<API> {
//    func fetchPokeList(completion: @escaping (Result<Data, Error>) -> Void) {
//        fetch(target: .pokemonList, dataType: Data.self) { result, _ in
//            switch result {
//            case .success(let success):
//                print(success)
//            case .failure(let failure):
//                print(failure)
//            }
//        }
//    }
//}
