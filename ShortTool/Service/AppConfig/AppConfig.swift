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
    var remoteConfig:RemoteConfig?
    var remoteConfigDict:[String:Any] = [String:Any]()
    
    //setup  fileprivate
    class func setup() {
        //初始化
        AppConfig.shared().configStatistics()
        AppConfig.shared().updateConfig()
        AppConfig.shared().updateJsonConfig()
    }
    // 初始化统计相关
    fileprivate func configStatistics() {
        FirebaseApp.configure()
        remoteConfig = RemoteConfig.remoteConfig()
              let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3
        remoteConfig!.configSettings = settings
    }
    
    fileprivate func updateConfig() {
        // TimeInterval is set to expirationDuration here, indicating the next fetch request will use
        // data fetched from the Remote Config service, rather than cached parameter values, if cached
        // parameter values are more than expirationDuration seconds old. See Best Practices in the
        // README for more information.
        remoteConfig!.fetch { (status, error) in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig!.activate(completionHandler: { (error) in
                    // ...
                })
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    func remoreConfigData(_ key:String) ->String? {
        if let tempConfig = self.remoteConfig {
            let value = tempConfig[key]
            return value.stringValue
        }
        return nil
    }
    
    func remoreConfigData2(_ key:String) ->String? {
        if self.remoteConfigDict.count > 0 {
            return self.remoteConfigDict[key] as? String
        }
        return nil
    }
    
    fileprivate func updateJsonConfig() {
        let url = "https://bllgo.com/short_url.json"
        Alamofire.request(url).responseJSON { (response) in
            if let JSON = response.result.value {
                let dict = JSON as! Dictionary<String, Any>
                self.remoteConfigDict = dict
                UserDefaults.standard.set(dict, forKey: "config")
            }
        }
    }
    
}
