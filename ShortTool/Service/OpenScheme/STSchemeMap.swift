//
//  STSchemeMap.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/20.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import Foundation
class STSchemeMap {
    //单例
    private static let shareSchemeMap: STSchemeMap = {
        let shared = STSchemeMap()
        return shared
    }()
    
    class func shared() ->STSchemeMap {
        return shareSchemeMap
    }
    
    private init() {
        
    }
    
    var schemmMap = ["home":"HomeViewController","ucenter":"MeViewController","batch":"BatchViewController"]
    
    class func controllerWith(_ key:String) ->String? {
        let strController = STSchemeMap.shareSchemeMap.schemmMap[key]
        return strController
    }
    
}
