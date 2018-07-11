//
//  AboudModel.swift
//  ShortTool
//
//  Created by Bllgo on 2018/7/6.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import Foundation

struct AboutModel: Codable {
    let id:String
    let title:String
    let subtitle:String
    let normalIcon:String
    let isclick:String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case subtitle
        case title
        case normalIcon = "normal_icon"
        case isclick
    }
}
