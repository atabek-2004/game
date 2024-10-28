//
//  SceneDelegate.swift
//  game
//
//  Created by Admin on 28.10.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MemoryGameViewController()
        window?.makeKeyAndVisible()
        print("SceneDelegate: window set to MemoryGameViewController")
    }
}

