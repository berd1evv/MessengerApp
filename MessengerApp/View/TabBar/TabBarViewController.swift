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
        viewControllers = [
            createTabBarItem(tabBarTitle: "", tabBarImage: "message.fill", viewController: ChatsViewController()),
            createTabBarItem(tabBarTitle: "", tabBarImage: "person.crop.circle.fill", viewController: ProfileViewController())
        ]
    }
    
    func createTabBarItem(tabBarTitle: String, tabBarImage: String, viewController: UIViewController) -> UIViewController {
        let navCont = viewController
        navCont.tabBarItem.title = tabBarTitle
        navCont.tabBarItem.image = UIImage(systemName: tabBarImage)
        
        return navCont
    }

}
