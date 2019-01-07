//
//  AppConfig.swift
//  ShortTool
//
//  Created by Bllgo on 2018/8/9.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class AppConfig: NSObject {
    //单例
    private static let shareConfig: AppConfig = {
        let shared = AppConfig()
        return shared
    }()
    
    class func shared() ->AppConfig {
        return shareConfig
    }
    
    private override init() {
        
    }
    
    // load
    @objc public static func swiftLoad() {
//        Swift.print("swift load")
    }
    
    @objc public static func swiftInitialize() {
//        Swift.print("swift Initialize")
        AppConfig.shared().updateConfig()
        AppConfig.shared().configStatistics()
    }
    //setup  fileprivate
    class func setup() {
        //初始化
    }
    // 初始化统计相关
    fileprivate func configStatistics() {
        FirebaseApp.configure()
    }
    
    fileprivate func updateConfig() {
        let url = "https://playkaixin.com/shortconfig.json"
        Alamofire.request(url).responseJSON { (response) in
            if let JSON = response.result.value {
                let dict = JSON as! Dictionary<String, Any>
                UserDefaults.standard.set(dict, forKey: "config")
            }
        }
    }
    
}
