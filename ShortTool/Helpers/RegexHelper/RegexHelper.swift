//
//  RegexHelper.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/22.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import Foundation
struct RegexHelper {
    let regex: NSRegularExpression
    init(_ pattern: String) throws{
        try regex = NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(input: String) ->Bool {
        let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.utf16.count))
        return matches.count > 0
    }
    
    static func isUrl(_ str:String) ->Bool {
        return str =~ "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
    }
    
    
}
//重载运算符方便你直接比较
infix operator =~

func =~(lhs:String,rhs:String) -> Bool {
    do{
        return try RegexHelper(rhs).match(input: lhs)
    }
    catch {
        return false
    }
}

