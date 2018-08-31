//
//  ShortenServiceManage.swift
//  ShortTool
//
//  Created by Bllgo on 2018/8/31.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import Foundation
class ServiceManage: NSObject {
    var serviceList = [ShortenServiceMode]()
    //单例
    private static let shareConfig: ServiceManage = {
        let shared = ServiceManage()
        return shared
    }()
    
    class func shared() ->ServiceManage {
        return shareConfig
    }
    
    private override init() {
        super.init()
        self.setup()
    }
    // load
    @objc public static func swiftLoad() {
        //        Swift.print("swift load")
    }
    
    @objc public static func swiftInitialize() {
        
    }
    //setup  fileprivate
    func setup() {
        //初始化
        self.serviceList = self.loadService()
    }
    
    func loadService() -> [ShortenServiceMode] {
        let jsonPath = Bundle.init(for: MainViewController.self).path(forResource: "service", ofType: "json")
        let data = try! Data.init(contentsOf: URL(fileURLWithPath: jsonPath!), options:.mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let services = try! decoder.decode([ShortenServiceMode].self, from: data)
        return services
    }
}
//"name":"t.cn",
//"sid":"sina",
//"api":"https://api.weibo.com/2/short_url/shorten.json",
//"parameter":"source=45678&url_long=http://google.com",
//"details":"由weibo提供的短链接服务"
struct ShortenServiceMode:Codable {
    var name:String
    var sid:String
    var api:String
    var parameter:String
    var details:String
    var enabled:Bool
}
