//
//  TabBarViewController.swift
//  MessengerApp
//
//  Created by Eldiiar on 27/3/22.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        tabBar.isTranslucent = false
        
        let chatNavBar = UINavigationController(rootViewController: ChatsViewController())
        viewControllers = [
            createTabBarItem(tabBarTitle: "Chats", tabBarImage: "message.fill", viewController: chatNavBar),
            createTabBarItem(tabBarTitle: "Profile", tabBarImage: "person.crop.circle.fill", viewController: ProfileViewController())
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func createTabBarItem(tabBarTitle: String, tabBarImage: String, viewController: UIViewController) -> UIViewController {
        let navCont = viewController
        navCont.tabBarItem.image = UIImage(systemName: tabBarImage)
        return navCont
    }

}
