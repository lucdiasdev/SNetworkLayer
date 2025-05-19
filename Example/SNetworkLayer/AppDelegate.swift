//
//  AppDelegate.swift
//  SNetworkLayer
//
//  Created by lucdiasdev on 02/10/2025.
//  Copyright (c) 2025 lucdiasdev. All rights reserved.
//

import UIKit
import SNetworkLayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        SNetworkLayerConfig.messageProvider = CustomErrorMessageProvider()
        
        let viewModel = ViewModelDemo()
        let viewController = ViewControllerDemo()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}




///MARK:  `para documentacao` como utilizar para mostrar os erros personalizados de network failure
final class CustomErrorMessageProvider: NetworkErrorMessageProvider {
    func message(for error: NetworkError) -> String {
        switch error {
        case .notConnectedNetwork:
            return "Você está offline. Verifique sua conexão com a internet."
        case .timeOut:
            return "A conexão está lenta. Tente novamente mais tarde."
        case .lostConnectedNetwork:
            return "A conexão com o servidor foi perdida."
        case .cancelConnectedNetwork:
            return "A operação foi cancelada."
        case .unknown:
            return "Ocorreu um erro desconhecido de rede."
        }
    }
}

///MARK:  `para documentacao` como utilizar se tiver um contrato de Error no backend de quem consome uma API
public protocol CustomNetworkError: Decodable {
    var code: String? { get }
    var message: String? { get }
    var additionalMessage: String? { get }
}

struct MyBackendError: CustomNetworkError {
    let code: String?
    let message: String?
    let additionalMessage: String?
}
