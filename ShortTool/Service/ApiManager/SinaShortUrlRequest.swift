//
//  SinaShortUrlRequest.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/14.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit

class SinaShortUrlRequest: XAFAPIBaseManager,XAFAPIManager,XAFAPIManagerParamSourceDelegate {
    var source = ""
    var longUrl = ""
    
    override init() {
        super.init()
        self.paramSource = self
//        self.sourc
    }
    convenience init(source:String = "2849184197", longUrl:String) {
        self.init()
        self.source = source
        self.longUrl = longUrl
        
    }
    //MARK: XAFAPIManager
    func methodName() -> String {
        return "2/short_url/shorten.json"
    }
    
    func serviceID() -> String {
        return "XAFServicesSina"
    }
    
    func requestType() -> String {
        return "GET"
    }
    
    //MARK: XAFAPIManagerParamSourceDelegate
    func paramsForApi(magager: XAFAPIBaseManager) -> Dictionary<String, String> {
        return ["source":self.source,"url_long":self.longUrl]
    }
}
