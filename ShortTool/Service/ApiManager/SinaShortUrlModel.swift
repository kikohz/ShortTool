//
//  SinaShortUrlModel.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/15.
//  Copyright © 2018 Bllgo. All rights reserved.
//

//import UIKit

struct SinaShortUrlModel: Codable {
    let result:Bool               //短链的可用状态，true：可用、false：不可用。
    let urlShort:String?
    let urlLong:String?
    let objectType:String?
    let type:Int                  //链接的类型，0：普通网页、1：视频、2：音乐、3：活动、5、投票
    let objectId:String?
    
    
    //自定义键名称
    //4.1 之后优化这部分，可以不用写 参照:https://benscheirman.com/2018/02/swift-4-1-keydecodingstrategy/
//    enum CodingKeys: String, CodingKey {
//        case result
//        case urlShort = "url_short"
//        case urlLong = "url_long"
//        case objectType
//        case type
//        case objectId = "object_id"
//    }
}

struct SinaUrlList: Codable {
    let urls:[SinaShortUrlModel]
}
