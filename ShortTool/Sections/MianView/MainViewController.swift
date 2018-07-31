//
//  MainViewController.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/19.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        var tabbarArray = [TabbarModel]()
        tabbarArray = self.loadTabbar()
        self.configTabbarWith(tabbarArray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadTabbar() -> [TabbarModel] {
        let jsonPath = Bundle.init(for: MainViewController.self).path(forResource: "tabbar", ofType: "json")
        let data = try! Data.init(contentsOf: URL(fileURLWithPath: jsonPath!), options:.mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase 
        let tabbar = try! decoder.decode([TabbarModel].self, from: data)
        return tabbar
    }
    
    func configTabbarWith(_ tabs:[TabbarModel]) {
        var navArray = [UINavigationController]()
        let titleColor = UIColor.init(hexString: "#a2a2a2")
        let titleTextAttSelectDict = [NSAttributedStringKey.foregroundColor : UIColor.init(hexString: "#ed4e39")]
        let titleTextAttDict = [NSAttributedStringKey.foregroundColor : titleColor]
        for (index,item) in tabs.enumerated() {
            if let pageName = STSchemeMap.controllerWith(item.page) {
                let aClass = NSObject.swiftClassFromString(className: pageName) as! UIViewController.Type
                let controller = aClass.init()
                controller.title = item.title
                let navController = UINavigationController.init(rootViewController: controller)
                //图标
                var icon = UIImage(named: item.normalIcon)
                var selectIcon = UIImage(named: item.normalIconSelect)
                if UIImage.instancesRespond(to: #selector(UIImage.withRenderingMode(_:))) {
                    if let tempIcon = icon, let tempSelectIcon = selectIcon {
                        icon = tempIcon.withRenderingMode(.alwaysOriginal)
                        selectIcon = tempSelectIcon.withRenderingMode(.alwaysOriginal)
                    }
                }
                //文案
                let barItem:UITabBarItem = UITabBarItem.init(title: item.title, image: icon, tag: index)
                
                barItem.setTitleTextAttributes(titleTextAttDict, for: .normal)
                barItem.setTitleTextAttributes(titleTextAttSelectDict, for: .selected)
//                barItem.titlePositionAdjustment = UIOffsetMake(0, 3)
                barItem.selectedImage = selectIcon
                //添加项目
                navController.tabBarItem = barItem
                navController.navigationBar.isTranslucent = true
                navController.extendedLayoutIncludesOpaqueBars = true
                navArray.append(navController)
            }
            
            self.tabBar.shadowImage = UIImage.init()
            var backImg = UIImage.init()
            if let img = UIImage.creatImg(UIColor.white) {
                backImg = img
            }
            self.tabBar.backgroundImage = backImg
        }
        self.tabBarController?.tabBar.isTranslucent = true
        self.viewControllers = navArray
    }
}

