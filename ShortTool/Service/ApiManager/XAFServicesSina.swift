//
//  XAFServicesSina.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/14.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit

class XAFServicesSina: XAFServices,XAFServicesProtocol {
    var isOnline: Bool {
        return false
    }
    
    var offlineApiBaseUrl: String = "https://p.bllgo.com/sina"
    
    var onlineApiBaseUrl: String = "https://p.bllgo.com/sina"
    
    var isSecurity: Bool {
        return false
    }
    
    required init() {
        super.init()
    }
    
    //MARK: 操作
    func signGetWithSigParams(allParams: Dictionary<String, Any>) -> String? {
        return "s"
        //        var tempStr = allParams.urlParamsStringSignature(isForSignature: true)
        //        tempStr += "xxxxxxxxxxxxxxxxxxxxxxx"
        //        tempStr = tempStr.md5!
        //        if tempStr.characters.count == 32 {
        //            let left = tempStr[0,15]
        //            let right = tempStr[15,31]
        //            tempStr = "\(left)_xxxxxxxxxx_\(right)"
        //            tempStr = tempStr.md5!
        //        }
        //        return tempStr
    }

}
